from opensearchpy import OpenSearch

# from opensearchpy import analyzer, tokenizer, Index


host = 'localhost'
port = 9200

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
  'settings': {
    'index': {
      'number_of_shards': 4
    },
    "analysis": {
      "analyzer": {
        "my_analyzer": {
          "tokenizer": "keyword",
          "filter": [ "my_custom_word_delimiter_filter" ]
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
# print(dir(client))

try:
    print(client.indices.analyze(
        index=index_name,
        body={
            "analyzer": "my_analyzer",
            "text": "Neil's-Super-Duper-XL500--42+AutoCoder"
        }
    ))
except Exception as e:
    print(e)
finally:
    response = client.indices.delete(
        index = index_name
    )
