<?php

namespace LaraWelP\Contracts\Options;

interface OptionsPage
{
    /**
     * Register settings page.
     * @return void
     */
    public function register();

    /**
     * The function to be called to output the content for this page.
     * @return void
     */
    public function render();

    /**
     * The slug name to refer to this menu by (should be unique for this menu).
     * @return string
     */
    public function menuSlug();

    /**
     * The text to be used for the menu.
     * @return string
     */
    public function menuTitle();

    /**
     * The text to be displayed in the title tags of the page when the menu is selected.
     * @return string
     */
    public function pageTitle();

    /**
     * The option-group to be used in the page.
     * @return string
     */
    public function optionGroup();

    /**
     * The option-name to be used in the page.
     * @return string
     */
    public function optionName();

    /**
     * The capability required for this menu to be displayed to the user.
     * @return string
     */
    public function capability();

    /**
     * The URL to the icon to be used for this menu.
     * @return string
     */
    public function iconUrl();

    /**
     * The position in the menu order this one should appear.
     * @return int
     */
    public function position();

    /**
     * The parent page of this page if any.
     * @return null|string|OptionsPage
     */
    public function parent();

    /**
     * Script to be enqueued.
     * @return string
     */
    public function scripts();

    /**
     * Style to be enqueued.
     * @return string
     */
    public function styles();
}
