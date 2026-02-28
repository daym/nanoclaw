(use-modules (guix packages)
             (guix git-download)
             (guix build-system node)
             (gnu packages node-xyz)
             ((guix licenses) #:prefix license:))

(define node-luxon
  (package
    (name "node-luxon")
    (version "3.7.2")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/moment/luxon")
               (commit version)))
        (file-name (git-file-name name version))
        (sha256
          (base32 "14mqf4ig310f296wbicpcfswflp8q8xf78s0g3fwds7zgzsja8iv"))))
    (build-system node-build-system)
    (arguments
      (list
        #:tests? #f
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'patch-dependencies 'delete-dev-dependencies
              (lambda _
                (modify-json (delete-dev-dependencies))))
            (add-after 'delete-dev-dependencies 'delete-build-scripts
              (lambda _
                (with-atomic-json-file-replacement
                  (lambda (pkg)
                    (map (lambda (kv)
                           (if (equal? (car kv) "scripts")
                               (cons "scripts"
                                     (filter
                                      (lambda (s)
                                        (not
                                         (member (car s)
                                                 '("prepare" "prepack"))))
                                      (cdr kv)))
                               kv))
                         pkg)))))
            (delete 'build)
            (add-before 'repack 'patch-exports
              (lambda _
                (substitute* "package.json"
                  (("\\.?/?build/es6/luxon\\.mjs") "./src/luxon.js")
                  (("\\.?/?build/node/luxon\\.js") "./src/luxon.js")
                  (("\\.?/?build/cjs-browser/luxon\\.js") "./src/luxon.js")))))))
    (home-page "https://moment.github.io/luxon/")
    (synopsis "Library for working with dates and times in JavaScript")
    (description "Luxon is a library for working with dates and times in
JavaScript.")
    (license license:expat)))

(define node-types-luxon
  (package
    (name "node-types-luxon")
    (version "3.7.1")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/DefinitelyTyped/DefinitelyTyped")
               (commit "45d75311249018701c43d9ad918ffa04283cf22a")))
        (file-name (git-file-name name version))
        (sha256
          (base32 "0hg1kz1kmb013l686kjd4bpsdd6s4136xx49ndw07l58x87i2ghh"))))
    (build-system node-build-system)
    (arguments
      (list
        #:tests? #f
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'unpack 'enter-type-directory
              (lambda _
                (chdir "types/luxon")
                (modify-json
                  (delete-dev-dependencies)
                  (replace-fields (list
                    (cons "version" "3.7.1")))))))))
    (synopsis "TypeScript definitions for luxon")
    (description "TypeScript definition files (*.d.ts) for luxon.")
    (home-page
      "https://github.com/DefinitelyTyped/DefinitelyTyped/tree/master/types/luxon")
    (license license:expat)))

(define node-cron-parser
  (package
    (name "node-cron-parser")
    (version "5.5.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/harrisiirak/cron-parser")
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
          (base32 "1pq2vd6mycf1yblfwl7xpk25q647y6awg42jwm5fa5s26gf7jq1y"))))
    (build-system node-build-system)
    (arguments
      (list
        #:tests? #f
        #:phases
        #~(modify-phases %standard-phases
            ;; Keep only @types/node and @types/luxon for tsc,
            ;; drop all other devDependencies.
            (add-after 'patch-dependencies 'delete-non-types-dev-dependencies
              (lambda _
                (with-atomic-json-file-replacement
                  (lambda (pkg)
                    (map (lambda (kv)
                           (if (equal? (car kv) "devDependencies")
                               (cons "devDependencies"
                                     (filter
                                      (lambda (dep)
                                        (member (car dep)
                                                '("@types/node"
                                                  "@types/luxon")))
                                      (cdr kv)))
                               kv))
                         pkg)))))
            (replace 'build
              (lambda _
                (invoke "tsc" "-p" "tsconfig.json"))))))
    (inputs (list node-luxon))
    (native-inputs (list node-typescript node-types-node node-types-luxon))
    (home-page "https://github.com/harrisiirak/cron-parser")
    (synopsis "Node.js library for parsing crontab instructions")
    (description "Node.js library for parsing crontab instructions.")
    (license license:expat)))

(packages->manifest
  (append
    (list node-luxon
          node-cron-parser)
    (map specification->package
      '("node"
        "node-anthropic-ai-claude-agent-sdk"
        "node-modelcontextprotocol-sdk"
        "node-zod"
        ;; "agent-browser"  ; TODO: package for Guix
        ;; "ungoogled-chromium"  ; TODO: takes forever to build
        "git"
        "sed"
        "gzip"
        "tar"
        "curl"
        "bash"
        "coreutils"
        "nss-certs"
        "font-liberation"
        "fontconfig"
        "which")))) ; claude code (in node-anthropic-ai-claude-agent-sdk) uses "which bash" to find bash
