// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/attribute.dart';
import 'package:dartdoc/src/model/model_element.dart';

abstract class ModelElementRenderer {
  const ModelElementRenderer();

  String renderLinkedName(ModelElement modelElement);

  String renderYoutubeUrl(String youTubeId, int width, int height);

  String renderAnimation(
      String uniqueId, int width, int height, Uri movieUrl, String overlayId);

  String renderAttributes(ModelElement modelElement) {
    var allAttributes = modelElement.attributes.toList(growable: false)
      ..sort(byAttributeOrdering);
    return allAttributes
        .map((f) =>
            '<span class="${f.cssClassName}">${f.linkedNameWithParameters}</span>')
        .join();
  }
}

class ModelElementRendererHtml extends ModelElementRenderer {
  const ModelElementRendererHtml();

  @override
  String renderLinkedName(ModelElement modelElement) {
    var cssClass = modelElement.isDeprecated ? ' class="deprecated"' : '';
    return '<a$cssClass href="${modelElement.href}">'
        '${modelElement.displayName}</a>';
  }

  @override
  String renderYoutubeUrl(String youTubeId, int width, int height) {
    // Blank lines before and after, and no indenting at the beginning and end
    // is needed so that Markdown doesn't confuse this with code, so be
    // careful of whitespace here.
    return '''

<iframe src="https://www.youtube.com/embed/$youTubeId?rel=0" 
        title="YouTube video player" 
        frameborder="0" 
        allow="accelerometer; 
               autoplay; 
               clipboard-write; 
               encrypted-media; 
               gyroscope; 
               picture-in-picture" 
        allowfullscreen="" 
        style="max-width: ${width}px;
               max-height: ${height}px;
               width: 100%;
               height: 100%;
               aspect-ratio: $width / $height;">
</iframe>

'''; // Must end at start of line, or following inline text will be indented.
  }

  @override
  String renderAnimation(
      String uniqueId, int width, int height, Uri movieUrl, String overlayId) {
    return '''

<div style="position: relative;">
  <div id="$overlayId"
       onclick="var $uniqueId = document.getElementById('$uniqueId');
                if ($uniqueId.paused) {
                  $uniqueId.play();
                  this.style.display = 'none';
                } else {
                  $uniqueId.pause();
                  this.style.display = 'block';
                }"
       style="position:absolute;
              width:${width}px;
              height:${height}px;
              z-index:100000;
              background-position: center;
              background-repeat: no-repeat;
              background-image: url(static-assets/play_button.svg);">
  </div>
  <video id="$uniqueId"
         style="width:${width}px; height:${height}px;"
         onclick="var $overlayId = document.getElementById('$overlayId');
                  if (this.paused) {
                    this.play();
                    $overlayId.style.display = 'none';
                  } else {
                    this.pause();
                    $overlayId.style.display = 'block';
                  }" loop>
    <source src="$movieUrl" type="video/mp4"/>
  </video>
</div>

'''; // Must end at start of line, or following inline text will be indented.
  }
}
