<?php

namespace LaraWelP\Contracts\Pagination;

interface Paginator
{
    /**
     * Get the URL range.
     *
     * @param int $from
     * @param int $to
     *
     * @return array
     */
    public function getUrlRange($from, $to);

    /**
     * Get the url.
     *
     * @param $pageNumber
     *
     * @return string
     */
    public function getUrl($pageNumber);

    /**
     * Get the URL for the next page.
     *
     * @return string|null
     */
    public function nextPageUrl();

    /**
     * Get the URL for the previous page.
     *
     * @return string|null
     */
    public function previousPageUrl();

    /**
     * Determine if there are more items in the data source.
     *
     * @return bool
     */
    public function hasMorePages();

    /**
     * Determine if there are enough items to split into multiple pages.
     *
     * @return bool
     */
    public function hasPages();

    /**
     * Determine if the paginator is on the first page.
     *
     * @return bool
     */
    public function onFirstPage();

    /**
     * Get the total number of items being paginated.
     *
     * @return int
     */
    public function total();

    /**
     * Get the last page.
     *
     * @return int
     */
    public function lastPage();

    /**
     * Get the number of items shown per page.
     *
     * @return int
     */
    public function perPage();

    /**
     * Get the current page.
     *
     * @return int
     */
    public function currentPage();

    /**
     * Render the contents of the paginator to HTML.
     *
     * @return string
     */
    public function toHtml();
}
