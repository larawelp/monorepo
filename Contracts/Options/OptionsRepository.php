<?php

namespace LaraWelP\Contracts\Options;

interface OptionsRepository
{
    /**
     * Get a particular value of an option in an options array.
     *
     * @param $key
     * @param null $default
     *
     * @return mixed
     */
    public function get($key, $default = null);

    /**
     * Update the option.
     *
     * @param $key
     * @param $value
     *
     * @return boolean
     */
    public function set($key, $value);

    /**
     * Delete the option from database.
     *
     * @return boolean
     */
    public function delete();

    /**
     * Get the option-name.
     * @return string
     */
    public function optionName();
}
