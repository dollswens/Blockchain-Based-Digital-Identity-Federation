;; Attribute Mapping Contract
;; Standardizes identity claims across different systems

(define-data-var admin principal tx-sender)

;; Map of attribute mappings
(define-map attribute-mappings
  {
    source-domain: (string-utf8 100),
    source-attribute: (string-utf8 100)
  }
  {
    target-attribute: (string-utf8 100),
    transformation: (string-utf8 255),
    created-at: uint,
    last-updated: uint
  }
)

;; Public function to create a new attribute mapping
(define-public (create-mapping
    (source-domain (string-utf8 100))
    (source-attribute (string-utf8 100))
    (target-attribute (string-utf8 100))
    (transformation (string-utf8 255))
  )
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (asserts! (not (is-some (map-get? attribute-mappings {
      source-domain: source-domain,
      source-attribute: source-attribute
    }))) (err u100))

    (ok (map-set attribute-mappings
      { source-domain: source-domain, source-attribute: source-attribute }
      {
        target-attribute: target-attribute,
        transformation: transformation,
        created-at: block-height,
        last-updated: block-height
      }
    ))
  )
)

;; Public function to get mapping details
(define-read-only (get-mapping (source-domain (string-utf8 100)) (source-attribute (string-utf8 100)))
  (map-get? attribute-mappings { source-domain: source-domain, source-attribute: source-attribute })
)

;; Public function to update an existing mapping
(define-public (update-mapping
    (source-domain (string-utf8 100))
    (source-attribute (string-utf8 100))
    (target-attribute (string-utf8 100))
    (transformation (string-utf8 255))
  )
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (asserts! (is-some (map-get? attribute-mappings {
      source-domain: source-domain,
      source-attribute: source-attribute
    })) (err u404))

    (match (map-get? attribute-mappings { source-domain: source-domain, source-attribute: source-attribute })
      mapping-data (ok (map-set attribute-mappings
        { source-domain: source-domain, source-attribute: source-attribute }
        {
          target-attribute: target-attribute,
          transformation: transformation,
          created-at: (get created-at mapping-data),
          last-updated: block-height
        }
      ))
      (err u404)
    )
  )
)

;; Public function to delete a mapping
(define-public (delete-mapping (source-domain (string-utf8 100)) (source-attribute (string-utf8 100)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (asserts! (is-some (map-get? attribute-mappings {
      source-domain: source-domain,
      source-attribute: source-attribute
    })) (err u404))

    (ok (map-delete attribute-mappings { source-domain: source-domain, source-attribute: source-attribute }))
  )
)
