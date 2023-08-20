<div class="js-larawelp-media-field larawelp-media-field {{ $has_value_class }}">
    <div class="larawelp-show-if-value--inline-block">
        <div class="larawelp-media-field__media {{ $media_type }}">
            <img class="larawelp-media-field__img" src="{{ $media_img_url }}">
            <ul class="larawelp-media-field__controller">
                <li><a class="larawelp-media-field__edit dashicons-before dashicons-edit"></a></li>
                <li><a class="larawelp-media-field__remove dashicons-before dashicons-trash"></a></li>
            </ul>
            <div class="larawelp-media-field__filename">{{ $filename }}</div>
        </div>
    </div>

    <div class="larawelp-hide-if-value">
        <input type="button" value="{{ $button_text }}" class="button larawelp-add-media-button">
    </div>

    {{ $description }}

    <input type="hidden" class="larawelp-media-field__input" name="{{ $field_name }}" value="{{ $attachment_id }}">
    <input type="hidden" value="{{ $media_uploader_options }}" class="larawelp-media-uploader-options">
</div>
