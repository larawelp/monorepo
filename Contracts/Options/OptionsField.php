<?php

namespace LaraWelP\Contracts\Options;

interface OptionsField
{
    /**
     * Register field to a specific page.
     *
     * @param OptionsPage|string $optionsPage       menu-slug of a page or a SettingsPage object
     * @param OptionsSection|string $optionsSection section-id of a section or a SettingsSection object
     * @param string $optionGroup                   The option-group to be used.
     * @param string $optionName                    The option-name to be used.
     * @param bool $hook                            Determine if call register functions in appropriate hook or not.
     *
     * @return void
     */
    public function register($optionsPage, $optionsSection, $optionGroup, $optionName, $hook = true);

    /**
     * The configurations of the field.
     *
     * @param null $name
     *
     * @return array
     */
    public function configs($name = null);

    /**
     * The option-group that this field is going to register or refer.
     * @return string
     */
    public function optionGroup();

    /**
     * The option-name that this field is going to register or refer.
     * @return string
     */
    public function optionName();

    /**
     * String for use in the 'id' attribute of tags.
     * @return string
     */
    public function id();

    /**
     * Title of the field.
     * @return string
     */
    public function title();

    /**
     * The type of the field.
     * @return string
     */
    public function type();

    /**
     * The capability required for this field to be displayed to the current user.
     * @return string
     */
    public function capability();
}
