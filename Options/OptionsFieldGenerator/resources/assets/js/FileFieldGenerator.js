jQuery(function ($) {

    function get_substitution_input(name) {
        return $('<input type="hidden" value="larawelp::removeFileField">').attr('name', name);
    }


    $('.js-larawelp-file-field').each(function () {
        var $field              = $(this),
            $input              = $field.find('.larawelp-file-field__input'),
            $filename           = $field.find('.larawelp-media-field__filename'),
            $substitution_input = $();

        $field.find('.larawelp-media-field__remove').on('click', function () {
            $field.removeClass('larawelp-has-value');
            $input.after($substitution_input = get_substitution_input($input.attr('name')));
        });

        $input.on('change', function () {
            $substitution_input.remove();
            $filename.text(this.files[0]['name']);
            $field.addClass('larawelp-has-value');
        });

    });
});
