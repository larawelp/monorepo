<?php

namespace LaraWelP\Support;

class Arr
{
    /**
     * Determines if an array is associative.
     *
     * @param  array $array
     *
     * @return bool
     */
    public static function isAssociative(array $array)
    {
        return ! static::isSequential($array);
    }

    /**
     * If the given array is sequential.
     *
     * @param array $array
     *
     * @return bool
     */
    public static function isSequential(array $array)
    {
        return array_keys($array) === range(0, count($array) - 1);
    }

    /**
     * Cast a variable to array.
     *
     * @param $var
     *
     * @return array
     */
    public static function cast($var)
    {
        return empty($var) ? [] : (array)$var;
    }
}
