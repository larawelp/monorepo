<div class="js-larawelp-file-field larawelp-media-field {{ $has_value_class }}">
    <div class="larawelp-show-if-value--inline-block">
        <div class="larawelp-media-field__media application">
            <img class="larawelp-media-field__img" src="{{ $media_img_url }}">
            <ul class="larawelp-media-field__controller">
                <li><a class="larawelp-media-field__remove dashicons-before dashicons-trash"></a></li>
            </ul>
            <div class="larawelp-media-field__filename">{{ $filename }}</div>
        </div>
    </div>

    <div class="larawelp-hide-if-value">
        <input type="file" name="{{ $field_name }}" class="larawelp-file-field__input">
    </div>

    {{ $description }}
</div>
