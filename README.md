Wercker step for QUAY Add Tag
=======================

# Example

```
deploy:
  steps:
    - wacul/quay-addtag:
        token: $QUAY_TOKEN
        repository: quay.io/wacul/example
        source_tag: latest
        add_tag: latest-web
```
