<?php

namespace LaraWelP\Support\Traits;

trait ClassHelper
{
    /**
     * Convert a map to properties.
     *
     * @param array $propertiesMap        A map to be converted to properties.
     * @param array $whiteListProperties  The properties that allowed to be converted.
     * @param array $requiredProperties   The required properties(keys of $propertiesMap).
     * @param callable|null $errorMessage The callable to return a error message that will be shown when the required property is not defined.
     */
    final protected function convertMapToProperties(
        array $propertiesMap,
        array $whiteListProperties,
        array $requiredProperties = [],
        callable $errorMessage = null
    ) {
        foreach ($requiredProperties as $requiredProperty) {
            if (!array_key_exists($requiredProperty, $propertiesMap)) {
                $defaultErrorMessage = "The `$requiredProperty` key is required.";
                throw new \InvalidArgumentException(
                    $errorMessage ? call_user_func_array($errorMessage, [$requiredProperty]) : $defaultErrorMessage
                );
            }
        }

        foreach ($whiteListProperties as $property) {
            if (isset($propertiesMap[$property])) {
                $this->{$property} = $propertiesMap[$property];
            }
        }
    }

    /**
     * Clone this object then change the state of the cloned object.
     *
     * @param array $newState A map of new state(key as property-name value as new property-value)
     * @param bool $deepCopy  Determine if do a deep copy. Can not copy property that is a closure.
     *
     * @return static
     */
    final protected function cloneAndChangeState(array $newState, $deepCopy = false)
    {
        $newObject = $deepCopy ? static::deepCopy($this) : clone $this;

        foreach ($newState as $property => $newValue) {
            $newObject->{$property} = $newValue;
        }

        return $newObject;
    }

    /**
     * Perform a deep copy of passed object.
     *
     * @param $object
     *
     * @return mixed
     */
    final public static function deepCopy($object)
    {
        $newObject = clone $object;
        $objectProperties = get_object_vars($newObject);

        foreach ($objectProperties as $objectPropertyName => $objectPropertyValue) {
            if (
                is_object($objectPropertyValue) and !($objectPropertyValue instanceof \Closure) or
                is_array($objectPropertyValue)
            ) {
                $newObject->{$objectPropertyName} = unserialize(serialize($objectPropertyValue));
            }
        }

        return $newObject;
    }
}
