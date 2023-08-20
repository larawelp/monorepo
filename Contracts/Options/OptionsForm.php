<?php

namespace LaraWelP\Contracts\Options;

interface OptionsForm
{
    public function text($name, array $configs = []);

    public function hidden($name, array $configs = []);

    public function number($name, array $configs = []);

    public function url($name, array $configs = []);

    public function email($name, array $configs = []);

    public function color($name, array $configs = []);

    public function search($name, array $configs = []);

    public function date($name, array $configs = []);

    public function time($name, array $configs = []);

    public function range($name, array $configs = []);

    public function checkbox($name, array $configs = []);

    public function checkboxes($name, array $configs = []);

    public function radios($name, array $configs = []);

    public function file($name, array $configs = []);

    public function media($name, array $configs = []);

    public function password($name, array $configs = []);

    public function textarea($name, array $configs = []);

    public function select($name, array $configs = []);
}
