<?php
// Run against an isolated Composer project; never boot a real WordPress database.
declare(strict_types=1);

function __($text, $domain = 'default') { return $text; }
function get_queried_object() { return null; }
function is_home() { return true; }
function get_template_directory() { return '/fixture/theme'; }
function add_filter($name, $callback, $priority = 10, $arguments = 1) { $GLOBALS['wp_filters'][$name][] = $callback; }

require ($argv[1] ?? __DIR__.'/vendor/autoload.php');

use Illuminate\Config\Repository;
use Illuminate\Foundation\Application;
use Illuminate\Http\Request;
use Illuminate\Routing\Route;
use Illuminate\Support\Facades\Facade;
use LaraWelP\Foundation\Routing\WpRouter;

$checks = 0;
function check(bool $condition, string $label): void {
    global $checks;
    if (!$condition) { throw new RuntimeException($label); }
    $checks++;
    echo "PASS: $label\n";
}

$base = sys_get_temp_dir().'/larawelp-test-'.bin2hex(random_bytes(6));
mkdir($base.'/bootstrap/cache', 0777, true);
mkdir($base.'/storage/framework/views', 0777, true);
$app = new Application($base);
$app->instance('config', new Repository([
    'app' => ['env'=>'testing', 'debug'=>false, 'key'=>str_repeat('a',32), 'url'=>'http://localhost'],
    'view' => ['paths'=>[], 'compiled'=>$base.'/storage/framework/views'],
    'cache' => ['default'=>'array', 'stores'=>['array'=>['driver'=>'array']]],
    'logging' => ['default'=>'null', 'channels'=>['null'=>['driver'=>'monolog','handler'=>Monolog\Handler\NullHandler::class]]],
]));
$app->instance('request', Request::create('/'));
Facade::setFacadeApplication($app);
$app->register(Illuminate\Filesystem\FilesystemServiceProvider::class);
$app->register(Illuminate\View\ViewServiceProvider::class);
$app->register(Illuminate\Translation\TranslationServiceProvider::class);
$app->register(Illuminate\Cache\CacheServiceProvider::class);
$app->register(Illuminate\Validation\ValidationServiceProvider::class);
$app->register(LaraWelP\Foundation\Providers\FoundationServiceProvider::class);
$app->register(LaraWelP\Foundation\Support\Wp\Providers\BladeDirectivesProvider::class);
$app->register(LaraWelP\Foundation\Support\Providers\RouteServiceProvider::class);
$app->singleton(Illuminate\Contracts\Debug\ExceptionHandler::class, Illuminate\Foundation\Exceptions\Handler::class);
$app->boot();
$app->bootstrapWith([]);
check(app('wpRouter') instanceof WpRouter, 'WordPress router registered alongside Laravel router');
check(config('larawelp.enable_folio_integration') === true, 'LaraWelP configuration booted');
check(__('WordPress text') === 'WordPress text', 'WordPress translation helper remains available');
if (function_exists('___')) {
    check(___('Laravel text') === 'Laravel text', 'Renamed Laravel translation helper works');
}
if (!class_exists(Corcel\Model\Post::class)) {
    $missingCorcel = false;
    try { (new Illuminate\Database\Eloquent\Builder(new Illuminate\Database\Query\Builder(new Illuminate\Database\Connection(null))))->queriedModels(); }
    catch (LogicException $exception) { $missingCorcel = str_contains($exception->getMessage(), 'jgrossi/corcel'); }
    check($missingCorcel, 'Optional Corcel integration explains a missing dependency');
}
check(str_contains(app('blade.compiler')->compileString('@loop @endloop'), 'wp_reset_postdata'), 'WordPress Blade directives compile');
check(Illuminate\Support\Facades\Blade::render('Hello {{ $name }}', ['name'=>'<world>']) === 'Hello &lt;world&gt;', 'Blade renders and escapes output');

$router = app('wpRouter');
$router->home(fn() => 'WordPress home');
$validators = Route::getValidators();
check($router->dispatch(Request::create('/'))->getContent() === 'WordPress home', 'WordPress condition route dispatches');
check(Route::getValidators() === $validators, 'Laravel validators restored after WordPress success');
$router->getRouter()->getRoutes()->refreshNameLookups();
$broken = new WpRouter(app('events'), $app);
try { $broken->dispatch(Request::create('/missing')); } catch (Symfony\Component\HttpKernel\Exception\NotFoundHttpException $exception) {}
check(Route::getValidators() === $validators, 'Laravel validators restored after WordPress exception');
app('router')->get('/ordinary', fn() => 'Laravel route');
check(app('router')->dispatch(Request::create('/ordinary'))->getContent() === 'Laravel route', 'Ordinary Laravel route still dispatches after WordPress exception');

$handled = null;
app('events')->listen(Illuminate\Foundation\Http\Events\RequestHandled::class, function ($event) use (&$handled) { $handled = $event->response; });
$kernel = new LaraWelP\Foundation\Http\Kernel($app, app('router'));
check($kernel->handle(Request::create('/ordinary')) === $kernel, 'WordPress HTTP handling defers until template selection');
$callback = end($GLOBALS['wp_filters']['template_include']);
check($callback('/fixture/theme/other.php') === '/fixture/theme/other.php' && $handled === null, 'Unrelated WordPress templates are preserved');
check($callback('/fixture/theme/index.php') === '/fixture/theme/index.php' && $handled->getContent() === 'Laravel route', 'WordPress template callback dispatches Laravel response');

if (class_exists(Laravel\Mcp\Server::class)) {
    $app->register(Laravel\Mcp\Server\McpServiceProvider::class);
    class CompatibilityTool extends Laravel\Mcp\Server\Tool {
        protected string $name = 'compatibility_echo';
        protected string $description = 'Returns a fixed compatibility test value.';
        public function handle(Laravel\Mcp\Request $request): Laravel\Mcp\Response { return Laravel\Mcp\Response::text('LaraWelP MCP works'); }
    }
    class CompatibilityServer extends Laravel\Mcp\Server {
        protected string $name = 'LaraWelP compatibility';
        protected array $tools = [CompatibilityTool::class];
    }
    Laravel\Mcp\Facades\Mcp::web('/mcp', CompatibilityServer::class);
    $rpc = function (string $method, array $params = []) use ($app) {
        $request = Request::create('/mcp','POST',[],[],[],['CONTENT_TYPE'=>'application/json','HTTP_ACCEPT'=>'application/json, text/event-stream'], json_encode(['jsonrpc'=>'2.0','id'=>1,'method'=>$method,'params'=>(object)$params]));
        $app->instance('request', $request);
        Facade::clearResolvedInstance('request');
        return json_decode($app['router']->dispatch($request)->getContent(), true, 512, JSON_THROW_ON_ERROR);
    };
    $init = $rpc('initialize', ['protocolVersion'=>'2025-11-25','capabilities'=>(object)[], 'clientInfo'=>['name'=>'test','version'=>'1']]);
    check(($init['result']['serverInfo']['name'] ?? null) === 'LaraWelP compatibility', 'Official Laravel MCP HTTP initialization');
    $list = $rpc('tools/list');
    check(($list['result']['tools'][0]['name'] ?? null) === 'compatibility_echo', 'Official Laravel MCP tool discovery');
    $call = $rpc('tools/call', ['name'=>'compatibility_echo','arguments'=>(object)[]]);
    check(($call['result']['content'][0]['text'] ?? null) === 'LaraWelP MCP works', 'Official Laravel MCP HTTP tool invocation');
}

// Console construction must also work outside a WordPress checkout (no false-path warnings).
$console = new LaraWelP\Foundation\Console\Kernel($app, app('events'));
check($console instanceof Illuminate\Foundation\Console\Kernel, 'Console kernel constructs without WordPress file present');
(new Illuminate\Filesystem\Filesystem)->deleteDirectory($base);
echo "$checks checks passed on Laravel ".Application::VERSION." / PHP ".PHP_VERSION."\n";
