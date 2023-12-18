from opensearchpy import OpenSearch

host = 'localhost'
port = 9200
documents = [
    {
        'title': "Moneyball's Leo James'",
        'director': 'Bennett Miller',
        'year': '2011'
    },
    {
        'title': "Moneyball Leo James",
        'director': 'Bennett Miller',
        'year': '2011'
    },
    {
        'title': "AbcmoneyballDf Leo James",
        'director': 'Bennett Miller',
        'year': '2011'
    },
    {
        'title': "moneyballDf Leo James",
        'director': 'Bennett Miller',
        'year': '2011'
    }

]

# Create the client with SSL/TLS and hostname verification disabled.
client = OpenSearch(
    hosts = ['https://admin:admin@localhost:9200/'],
    http_compress = True, # enables gzip compression for request bodies
    use_ssl = True,
    verify_certs = False,
    ssl_assert_hostname = False,
    ssl_show_warn = False
)

index_name = 'python-test-index'
index_body = {
  'mappings': {
    "properties":{
        'python-test-index': {
            "properties": {
                "title": {
                    "type": "text",
                    # "analyzer": "my_analyzer"
                    # "analyzer": "english",
                },
                "director": {
                    "type": "text"
                },
                "year": {
                    "type": "text"
                }
            }
        }
    }
  },
  'settings': {
    'index': {
      'number_of_shards': 4
    },
    "analysis": {
      "analyzer": {
        "my_analyzer": {
          "tokenizer": "keyword",
          "filter": [ "lowercase", "my_custom_word_delimiter_filter" ]
        }
      },
      "filter": {
        "my_custom_word_delimiter_filter": {
          "type": "word_delimiter",
          "type_table": [ "- => ALPHA" ],
          "split_on_case_change": False,
          "split_on_numerics": False,
          "stem_english_possessive": True,
          "preserve_original": True
        }
      }
    }
  }
}

response = client.indices.create(index_name, body=index_body)

try:
    for i, doc in enumerate(documents):
        response = client.index(
            index = index_name,
            body = doc,
            id = f"{i+1}",
            refresh = True
        )

    for q in ["moneyball", "moneyball's",
        "moneyball's OR moneyball", "Leo abc",
        "James", "James'"]:
        query = {
            'size': 5,
            'query': {
                'multi_match': {
                    "analyzer": "my_analyzer",
                    # "analyzer": "standard",
                    # "analyzer": "simple",
                    # "analyzer": "english",
                    'query': q,
                    "type": "bool_prefix", # potential fix
                    # "type": "phrase_prefix", # no
                    'fields': ['title'],
                }
            }
        }

        response = client.search(
            body = query,
            index = index_name
        )
        print(response['hits']['total']['value'])
        print([hit['_source'] for hit in response['hits']['hits']])
        # print(response)

    for text in [
        "Neil's-Super-Duper-XL500--42+AutoCoder",
        "Moneyball's Leo",
        "Moneyball Leo",
        "moneyball"]:
        res = client.indices.analyze(
            index=index_name,
            body={
                "analyzer": "my_analyzer",
                "text": text
            })
        print([token["token"] for token in res["tokens"]])
except Exception as e:
    print(e)
finally:
    response = client.indices.delete(
        index = index_name
    )
