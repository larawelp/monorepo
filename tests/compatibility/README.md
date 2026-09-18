# Compatibility checks

These tests install their own framework and never load the blog's WordPress database, credentials, or vendor directory. WordPress functions are minimal in-memory fixtures: this is a bridge/transport test, not a full WordPress integration suite.

```sh
cd tests/compatibility
composer install
composer test
```

The default fixture uses Laravel 13 (PHP 8.3+) and the official `laravel/mcp` package. The CI matrix also tests Laravel 12 on PHP 8.2. To test a different installed framework without changing the theme:

```sh
php tests/compatibility/run.php /absolute/path/to/isolated/vendor/autoload.php
```

Checks cover provider registration, WordPress Blade directives and escaping, WordPress conditional routing, restoration of Laravel validators on success and failure, ordinary Laravel routes, deferred WordPress template handling, console construction, and official MCP HTTP initialize/discovery/tool calls. MCP checks run only when that package is installed; Laravel 10 cannot load it.

`composer.json` uses a relative path repository back to the monorepo. Generated vendor and lock files are intentionally ignored. The post-autoload script exercises the WordPress/Laravel translation-helper compatibility patch.
