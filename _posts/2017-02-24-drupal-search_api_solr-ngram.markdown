---
layout: post
title: "Drupal, search_api_solr and Partial Matches"
date: 2017-02-24 20:10:00 -0400
comments: true
sidebar: false
categories: drupal solr search_api search_api_solr
---

Configuring solr to return [partial matches through Drupal's search_api_solr is well documented](https://www.google.ca/search?q=search_api_solr+partial+matches). In particular, one [d.o document](https://www.drupal.org) is thorough and stands out: [Customizing the Solr configuration](https://www.drupal.org/node/200976). It states:

> First, copy a text type definition to schema_extra_types.xml and change the identifier, as described above.
> Then, add the following line to the type definition after the first occurrence of "solr.SnowballPorterFilterFactory" (inside of the <analyzer type="index"> element; not after the second occurrence):
>
> <filter class="solr.EdgeNGramFilterFactory" minGramSize="2" maxGramSize="25" />
>
> If you want partial matches inside of words to be found, too, simply remove the "Edge" part from that line. In this case, you should also remove both occurrences of the solr.WordDelimiterFilterFactory filters: remove everything from the <filter that preceeds that string to the "great than" sign (>) coming after it.

Sounds great! Adding the _NGramFilterFactory_ filter after the _SnowballPorterFilterFactory_ seems a bit befuddling at first (both _SnowballPorterFilterFactory_ and _NGramFilterFactory_ tokenize the strings). Doubly creating tokens seems to be a bit redundant, however with small enough ngram sizes I suppose it might be of benefit. Also, _SnowballPorterFilterFactory_ does appear to store the original string, which may not be done in a _NGramFilterFactory_ filter if a ```maxGramSize``` of less than the string length is specified. Or does it?

I'm nattering. All of this isn't the point here : I'm certainly not a solr expert and couldn't speak to common use cases.

## Initial Results
Regardless, a configuration as above does indeed deliver partial matching functionality in results, but **with relevance scores where partial and exact field matches are ranked equally**. An exact match would only be one of many equally-scored derived tokens. In these cases, the order they appear in search results would depend on the secondary sort.

So yes, the many documents that advise changing the _text_ fieldType filters to add _NGramFilterFactory_ (or creating a new type, and assigning that to the ts_* dynamic field), does solve the partial matching problem.

But that isn't our desired goal or UX in most cases we've faced. I believe that **users who type _exact_ node titles into search boxes would generally expect to see those first in a result set, followed by those that match _somewhat_, and then _less-and-less_**.

## The Goal
So, what we REALLY want is for solr to return a result set where:

* Partial matching is considered across all fields
* EXACT matches on certain fields are scored higher and given more relevancy.

## Solution
For this solution, consider the title field as the one to boost for an exact match.

### 1) Edit Solr Configuration Files
On your solr server, add a new field type, ```text_ngram``` to the schema:

#### Update _solr_extra_types.xml_

In ```<types>```, add a new ngrammed field type for text:

```
    <fieldType name="text_ngram" class="solr.TextField" positionIncrementGap="100">
      <analyzer type="index">
        <charFilter class="solr.MappingCharFilterFactory" mapping="mapping-ISOLatin1Accent.txt"/>
        <tokenizer class="solr.WhitespaceTokenizerFactory"/>
        <!-- in this example, we will only use synonyms at query time
        <filter class="solr.SynonymFilterFactory" synonyms="index_synonyms.txt" ignoreCase="true" expand="false"/>
        -->
        <!-- Case insensitive stop word removal. -->
        <filter class="solr.StopFilterFactory"
                ignoreCase="true"
                words="stopwords.txt"
                />
        <filter class="solr.LengthFilterFactory" min="2" max="100" />
        <filter class="solr.LowerCaseFilterFactory"/>
        <filter class="solr.NGramFilterFactory" minGramSize="3" maxGramSize="15" />
        <filter class="solr.RemoveDuplicatesTokenFilterFactory"/>
      </analyzer>
      <analyzer type="query">
        <charFilter class="solr.MappingCharFilterFactory" mapping="mapping-ISOLatin1Accent.txt"/>
        <tokenizer class="solr.WhitespaceTokenizerFactory"/>
        <filter class="solr.SynonymFilterFactory" synonyms="synonyms.txt" ignoreCase="true" expand="true"/>
        <filter class="solr.StopFilterFactory"
                ignoreCase="true"
                words="stopwords.txt"
                />
        <filter class="solr.LengthFilterFactory" min="2" max="100" />
        <filter class="solr.LowerCaseFilterFactory"/>
        <filter class="solr.RemoveDuplicatesTokenFilterFactory"/>
      </analyzer>
      <analyzer type="multiterm">
        <charFilter class="solr.MappingCharFilterFactory" mapping="mapping-ISOLatin1Accent.txt"/>
        <tokenizer class="solr.WhitespaceTokenizerFactory"/>
        <filter class="solr.SynonymFilterFactory" synonyms="synonyms.txt" ignoreCase="true" expand="true"/>
        <filter class="solr.StopFilterFactory"
                ignoreCase="true"
                words="stopwords.txt"
                />
        <filter class="solr.LengthFilterFactory" min="2" max="100" />
        <filter class="solr.LowerCaseFilterFactory"/>
        <filter class="solr.RemoveDuplicatesTokenFilterFactory"/>
      </analyzer>
    </fieldType>
```

#### Update _schema.xml_

Alter the default ts_* fieldtype to be the new text_ngram, tokenizing the values. In ```<fields>```, change:

```
    <field name="ts_*" type="text" indexed="true"  stored="true" multiValued="false" termVectors="true" />
```

to

```
    <field name="ts_*" type="text_ngram" indexed="true"  stored="true" multiValued="false" termVectors="true" />
```

Then add an exact match element for title and set it as text.

```
    <field name="ts_title" type="text" indexed="true"  stored="true" multiValued="false" termVectors="true" />
```

### 2) Restart Solr
Restart solr to load the new schema.

### 3) Update search_api_solr Drupal configuration
Navigate to ```/admin/config/search/search-api/index/*INDEXNAME*/fields``` in Drupal.

Ensure  the title field exists twice in the field list, each with machine names:
* ```title``` : FULLTEXT with Boost 21.0 (Exact title matches as specified in schema.xml)
* ```title_ngram``` : FULLTEXT with Boost 15.0  (Partial matches on title, uses dynamic ts_*)

Verify that all other fields that should indexed are are listed in the field tab.

### 4) Delete Indexed documents and reindex in Drupal
Navigate to ```admin/config/search/search-api/index/pm_portal``` in Drupal.

* Click "Clear all indexed data"
* Click "Index now" beside 'Index all items'
