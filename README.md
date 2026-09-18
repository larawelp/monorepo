# LaraWelP

WordPress integration for Laravel: Laravel routes, Blade views, service providers, and Artisan alongside WordPress.

## Laravel compatibility

The monorepo package (`larawelp/all`) and split Foundation package now declare Laravel 10–13 compatibility. PHP requirements follow the selected framework: Laravel 10 requires PHP 8.1+, Laravel 11/12 require PHP 8.2+, and Laravel 13 requires PHP 8.3+. New installations should use a supported Laravel release.

`larawelp/all` declares its framework dependency and replaces the Foundation package as well as Contracts, Options, Pagination, and Support. It must not be installed together with a second copy of Foundation.

The core WordPress bridge does not require Corcel, Folio, or Horizon:

- Install **Corcel** if you use the Eloquent `queriedModels()` macro. Without it, that macro now gives a specific installation error. Match the Corcel release/fork to your Laravel version. Stock Corcel 9 currently declares Laravel 12, not 13.
- Install **Folio** for file-based routing. The bridge already checks whether Folio is installed and enabled.
- Install **Horizon** if your application uses its queue dashboard.

These remain explicit dependencies of the bundled Theme starter, preserving its existing features. Decoupling them from Foundation allows other WordPress/Laravel applications to upgrade the bridge without inheriting unrelated application dependencies. The bundled Theme starter uses the configured Corcel fork; choose a revision that supports your target Laravel version.

### Existing applications

Keep your application's existing kernel/provider layout. Upgrade the framework and application dependencies together; merely widening LaraWelP's version constraint does not upgrade an application.

1. Check PHP in both the CLI and the web server (PHP-FPM/Herd).
2. Review the Laravel [11](https://laravel.com/docs/11.x/upgrade), [12](https://laravel.com/docs/12.x/upgrade), and [13](https://laravel.com/docs/13.x/upgrade) upgrade guides for the versions crossed.
3. Resolve all Composer constraints without version aliases that pretend an older framework is installed. In particular, inspect Corcel, application authentication providers, Livewire, and custom SDK forks.
4. Retain the `LaraWelP\Foundation\ComposerScripts::renameHelperFunctions` post-autoload hook so Laravel's translation helper does not collide with WordPress's `__()`.
5. Run the bridge compatibility suite and the application's own integration tests. Validate normal pages, REST routes, login, and Artisan against a test database before production rollout.

Compatibility changes include explicit nullable types for PHP 8.4, restoring Laravel route validators even when WordPress routing throws, restoring the original router after middleware synchronization, handling `Throwable` in the HTTP bridge, and safe console boot when WordPress is absent/already initialized.

## Official Laravel MCP

Laravel 13 can install the official [`laravel/mcp`](https://github.com/laravel/mcp) package normally. The isolated tests verify HTTP initialization, tool discovery, and a tool call through `Mcp::web()` on the same Laravel router used by LaraWelP.

```sh
composer require laravel/mcp:^1.0
```

Application-specific MCP servers, authorization, cache exclusions, and WordPress response emission remain application concerns. The test server is a fixture; it does not expose a live endpoint or health data.

See [compatibility checks](tests/compatibility/README.md) for local commands and test boundaries.

## Application validation

The pacurar2020 integration was upgraded locally to Laravel 13.32.0 on PHP 8.4, using compatibility updates in its Corcel, currency, and MultiversX forks. All 194 health integration checks passed. Application dependencies and PHP-FPM still need to be upgraded together when deploying an existing application; this library does not deploy or switch any site runtime.
