---
title: "Drupal Custom Content Entities: Post-Module-Install Field Changes"
date: 2018-12-09T08:53:56-04:00
comments: true
tags: ["drupal", "custom entities", "update hooks"]
---
At some point in their lifecycle, most custom Entities in Drupal will require structural changes.

Schema evaluation and the provisioning of storage for a custom content Entity occurs automatically only once - when the module that defines that entity is installed. Conversely, a custom content Entity's form structure, elements, and properties are read from the ```src/Entity/EntityName.php``` entity definition each time it is rendered. As a result, any schema-changing modifications after module installation will leave a Drupal instance in corrupted limbo: UI/form elements for the Entity no longer synchronized with the previously-installed storage definition.

### drush entup
Drush's provides ```entup``` as a simple to use mechanism to automatically update entities after schema without destroying existing content. It is an excellent tool for development environments, where content is usually disposable. Relying on ```drush entup``` in a production is *asking for a catastrophe*, as it provides no architecture to specify how to crosswalk data types and can easily lead to corrupted data in production after even simple schema changes.

### hook_update()
When changing existing entity field definitions in production, the safe method to migrate field data is to use hook_update() to explicitly control the data crosswalk. Specifically:

 * Modify the Entity definition in ```src/Entity/EntityName.php```
 * Implement hook_update() to perform the specific schema/storage changes for sites that have previously installed the module.

Although not as simple as ```drush entup```, this process is the [recommended method to change existing field types on d.o.](https://www.drupal.org/node/2554097#change-field-schema). 

## Example
Information on implementing hook_update() in a module [is available on d.o](https://www.drupal.org/docs/7/creating-custom-modules/howtos/examples-for-database-update-scripts-using-hook_update_n-how). A topical implementation that removes a field from an entity:

{{< highlight PHP >}}
function modulename_update_8001() {
  $update_manager = Drupal::service('entity.definition_update_manager');
  $definition = $update_manager->getFieldStorageDefinition('fieldname', 'entity_id');
  $update_manager->uninstallFieldStorageDefinition($definition);
  return t('Entity: field was uninstalled');
}
{{< / highlight >}}
{{< reference "https://techblog.stefan-korn.de/content/remove-base-field-custom-content-entity-drupal-8" >}}

## Content Entity Schema/Storage Changes : Other Operations

### Remove an Existing Field From Custom Content Entities
The Entity Definition Update Manager provides the method [uninstallFieldStorageDefinition()](https://api.drupal.org/api/drupal/core%21lib%21Drupal%21Core%21Entity%21EntityDefinitionUpdateManagerInterface.php/function/EntityDefinitionUpdateManagerInterface%3A%3AuninstallFieldStorageDefinition/8.2.x), which can be leveraged to delete a field's existing storage definition for a custom entity:
{{< highlight PHP >}}
$update_manager = Drupal::service('entity.definition_update_manager');
$definition = $update_manager->getFieldStorageDefinition('fieldname', 'entity_id');
$update_manager->uninstallFieldStorageDefinition($definition);
{{< / highlight >}}

### Add a Field to Custom Content Entities
The Entity Definition Update Manager provides the method [installFieldStorageDefinition()](https://api.drupal.org/api/drupal/core%21lib%21Drupal%21Core%21Entity%21EntityDefinitionUpdateManagerInterface.php/function/EntityDefinitionUpdateManagerInterface%3A%3AinstallFieldStorageDefinition/8.2.x), which can be leveraged to add the new field storage definition for a custom entity.

{{< highlight PHP >}}
$definition_update_manager = \Drupal::entityDefinitionUpdateManager();

  // Add the publishing status field to the block_content entity type.
$status = BaseFieldDefinition::create('boolean')
->setLabel(new TranslatableMarkup('Publishing status'))
->setDescription(new TranslatableMarkup('A boolean indicating the published state.'))
->setRevisionable(TRUE)
->setTranslatable(TRUE)
->setDefaultValue(TRUE);
$has_content_translation_status_field = $definition_update_manager
->getFieldStorageDefinition('content_translation_status', 'block_content');
if ($has_content_translation_status_field) {
$status
->setInitialValueFromField('content_translation_status', TRUE);
}
else {
  $status
    ->setInitialValue(TRUE);
}
$definition_update_manager
  ->installFieldStorageDefinition('status', 'block_content', 'block_content', $status);
{{< / highlight >}}
{{< reference "https://api.drupal.org/api/drupal/core%21modules%21block_content%21block_content.install/function/block_content_update_8400/8.5.x" >}}

### Change Field Types in Custom Content Entities
Changing the type of a custom Entity field is a more complex operation. At the core of the complexity: cross-walking data between the old field type into the new.

To illustrate this: imagine a module maintainer needed to change a string type field into a Taxonomy term reference field. Cross-walking the data requires the creation of the new taxonomy term Entities while considering duplication, string case, whitespace, and equivalencies in the existing field data.

A generalized list of steps for most field type change operations:

 * Read all field data into non-database storage.
 * Iterate over this new storage, and perform any operations required to convert that field's data into the new type.
 * Remove the field from the custom entity.
 * Create the new desired field on the custom entity.
 * Iterate over the non-database storage and insert each item as a new value.

Case study: maintainers of the [fillpdf](https://www.drupal.org/project/fillpdf) module needed to convert an _entity reference_ field to a _file_ field. Their hook_update() implementation follows:

{{< highlight PHP >}}
$definition_update_manager = \Drupal::entityDefinitionUpdateManager();
$entity_manager = \Drupal::entityManager();
$db = \Drupal::database();

$form_file_def = BaseFieldDefinition::create('file')
  ->setLabel(t('The associated managed file.'))
  ->setDescription(t('The associated managed file.'))
  ->setName('file')
  ->setProvider('fillpdf_form')
  ->setTargetBundle(NULL)
  ->setTargetEntityTypeId('fillpdf_form');

$fc_file_def = BaseFieldDefinition::create('file')
  ->setLabel(t('The associated managed file.'))
  ->setDescription(t('The associated managed file.'))
  ->setName('file')
  ->setProvider('fillpdf_file_context')
  ->setTargetBundle(NULL)
  ->setTargetEntityTypeId('fillpdf_file_context');

// Save existing data.
$form_files = $db->select('fillpdf_forms', 'ff')
  ->fields('ff', ['fid', 'file'])
  ->execute()
  ->fetchAllKeyed();

$fc_files = $db->select('fillpdf_file_context', 'fc')
  ->fields('fc', ['id', 'file'])
  ->execute()
  ->fetchAllKeyed();

// Remove data from the storage.
$db->update('fillpdf_forms')
  ->fields(['file' => NULL])
  ->execute();

$db->update('fillpdf_file_context')
  ->fields(['file' => NULL])
  ->execute();

// Now install the new field definitions.
$definition_update_manager->updateFieldStorageDefinition($form_file_def);
$definition_update_manager->updateFieldStorageDefinition($fc_file_def);

foreach ($form_files as $entity_id => $fillpdf_form_file) {
  $entity = $entity_manager->getStorage('fillpdf_form')->load($entity_id);
  $entity->file->target_id = $fillpdf_form_file;
  $entity->save();
}

foreach ($fc_files as $entity_id => $ffcf) {
  $entity = $entity_manager->getStorage('fillpdf_file_context')->load($entity_id);
  $entity->file->target_id = $ffcf;
  $entity->save();
}
{{< / highlight >}}
{{< reference "https://git.drupalcode.org/project/fillpdf/blob/8.x-4.x/fillpdf.install" >}}

It is important to note that the above snippet *risks loss of data*, as it stores the original field values in memory as a local PHP array. Any exceptions that occur within the update hook may leave the update in a unrecoverable state. You may consider leveraging an external data store and database transactions to make the update data-safe.

### Change a Property of a Custom Content Entity's Field (i.e. Length)
The operation list for changing the property of a custom entity's field is similar to changing type.

A generalized list of steps for most field property change operations:

 * Read all field data into non-database storage.
 * Iterate over this new storage, and audit/perform any operations required to convert that field's data to fit the new property.
 * Remove the field from the custom entity.
 * Create the new desired field on the custom entity.
 * Iterate over the non-database storage and insert each item as a new value.

The snippet for this operation would be similar to that of changing it's type. See above.
