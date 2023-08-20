<?php

namespace LaraWelP\Support;

class Transient
{
    /** @var string */
    protected $transientName;

    /** @var  int */
    protected $expiration;

    /**
     * AccessToken constructor.
     *
     * @param string $transientName
     * @param int $expiration
     */
    public function __construct($transientName, $expiration = 0)
    {
        $this->transientName = $transientName;
        $this->expiration    = $expiration;
    }

    public function save($data)
    {
        set_transient($this->transientName, $data, $this->expiration);
    }

    public function clear()
    {
        delete_transient($this->transientName);
    }

    public function get()
    {
        return get_transient($this->transientName);
    }
}
