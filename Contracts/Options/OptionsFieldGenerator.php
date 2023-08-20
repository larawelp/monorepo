<?php

namespace LaraWelP\Contracts\Options;

interface OptionsFieldGenerator
{
    /**
     * Generate the field markup.
     *
     * @return string
     */
    public function generate();

    /**
     * A callback function that sanitizes the option's value.
     *
     * @param mixed $value
     *
     * @return mixed
     */
    public function sanitize($value);
}
