<?php

namespace LaraWelP\Support;

/**
 * A dead simple template engine to search and replace
 * any markup like `{{ $var }}` to the corresponding string.
 * @package LaraWelP\Support
 */
class Template
{
    private $template;

    /**
     * Template constructor.
     *
     * @param string $template
     */
    public function __construct($template)
    {
        $this->template = $template;
    }

    /**
     * @param array $data
     *
     * @return string
     */
    public function render(array $data)
    {
        $patterns     = [];
        $replacements = [];

        foreach ($data as $key => $value) {
            $patterns[]     = sprintf('/{{\s*\$%s\s*}}/', $key);
            $replacements[] = (string)$value;
        }

        return preg_replace($patterns, $replacements, $this->template);
    }
}
