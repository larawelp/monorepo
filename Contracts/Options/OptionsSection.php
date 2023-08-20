<?php

namespace LaraWelP\Contracts\Options;

interface OptionsSection
{
    /**
     * Register the section to a specific page.
     *
     * @param OptionsPage|string $optionsPage menu-slug of a page or a SettingsPage object
     * @param string $optionGroup             The option-group to be used.
     * @param string $optionName              The option-group to be used.
     * @param bool $hook                      Determine if call register functions in appropriate hook or not.
     *
     * @return void
     */
    public function register($optionsPage, $optionGroup, $optionName, $hook = true);

    /**
     * Function that fills the section with the desired content. The function should echo its output.
     * @return void
     */
    public function render();

    /**
     * The id of the section.
     * @return string
     */
    public function id();

    /**
     * Title of the section.
     * @return string
     */
    public function title();

    /**
     * The capability required for this field to be displayed to the current user.
     * @return string
     */
    public function capability();

    /**
     * The description of the section.
     * @return string
     */
    public function description();
}
