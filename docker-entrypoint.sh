#!/bin/sh
until curl -u elastic:changeme -XGET elasticsearch:9200/; do
  >&2 echo "Failed to configure Elasticsearch, it's unavailable - sleeping 5s"
  sleep 5
done

>&2 echo "Elasticsearch is up - Set bro mapping"
curl -u elastic:changeme -XPUT elasticsearch:9200/_template/fixstrings_bro -d '{
  "template": "bro-*",
    "index": {
      "number_of_shards": 3,
      "number_of_replicas": 1
    },
    "mappings" : {
      "http" : {
        "properties" : {
          "status_msg" : {
            "type" : "text",
            "index" : "not_analyzed"
          },
          "user_agent" : {
            "type" : "text",
            "index" : "not_analyzed"
          },
          "uri" : {
            "type" : "text",
            "index" : "not_analyzed"
          }
        }
      },
        "conn" : {
          "properties" : {
            "orig_location" : {
              "type" : "geo_point"
            },
            "resp_location" : {
              "type" : "geo_point"
            }
          }
      },
      "files" : {
        "properties" : {
          "mime_type" : {
            "type" : "text",
            "index" : "not_analyzed"
          }
        }
      },
      "location": {
        "properties" : {
          "ext_location" : {
            "type" : "geo_point"
          }
        }
      },
      "notice" : {
        "properties" : {
          "note" : {
            "type" : "text",
            "index" : "not_analyzed"
          }
        }
      },
      "ssl" : {
        "properties" : {
          "validation_status" : {
            "type" : "text",
            "index" : "not_analyzed"
          },
          "server_name" : {
            "type" : "text",
            "index" : "not_analyzed"
          }
        }
      },
      "dns" : {
        "properties" : {
          "answers" : {
            "type" : "text",
            "index" : "not_analyzed"
          },
          "query" : {
            "type" : "text",
            "index" : "not_analyzed"
          }
        }
      },
      "intel" : {
        "properties" : {
          "sources" : {
            "type" : "text",
            "index" : "not_analyzed"
          },
          "seen_indicator_type" : {
            "type" : "text",
            "index" : "not_analyzed"
          },
          "seen_where" : {
            "type" : "text",
            "index" : "not_analyzed"
          }
        }
      },
      "weird" : {
        "properties" : {
          "name" : {
            "type" : "text",
            "index" : "not_analyzed"
          },
          "query" : {
            "type" : "text",
            "index" : "not_analyzed"
          }
        }
      }
    }
  }'

exec "$@"
