/*
 ~   Copyright (c) WSO2 Inc. (http://wso2.com) All Rights Reserved.
 ~
 ~   Licensed under the Apache License, Version 2.0 (the "License");
 ~   you may not use this file except in compliance with the License.
 ~   You may obtain a copy of the License at
 ~
 ~        http://www.apache.org/licenses/LICENSE-2.0
 ~
 ~   Unless required by applicable law or agreed to in writing, software
 ~   distributed under the License is distributed on an "AS IS" BASIS,
 ~   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 ~   See the License for the specific language governing permissions and
 ~   limitations under the License.
 */

/**
 * @description Check jQuery
 * @throw  {String}  throw an exception message if jquery is not loaded
 */
if (typeof(jQuery) === 'undefined') {
  throw 'jQuery is required.';
}

(function($) {
/**
 * @description Dependancy injection function
 * @param  {String}     File    Name of the dependancy
 * @param  {String}     Type    Dependancy type
 * @return {Null}
 */
$.required = function(file, filetype) {
    var markup = 'undefined';

    if (filetype == 'js') { //if filename is a external JavaScript file
        markup = document.createElement('script');
        markup.setAttribute("type", "text/javascript");
        markup.setAttribute("src", file);
    } else if (filetype == 'css') { //if filename is an external CSS file
        markup = document.createElement('link');
        markup.setAttribute("rel", "stylesheet");
        markup.setAttribute("type", "text/css");
        markup.setAttribute("href", file);
    }

    if (typeof markup != 'undefined') {
        if (filetype == 'js') {
            $('html script[src*="theme-wso2.js"]').before(markup);
        } else if (filetype == 'css') {
            $('head link[href*="main.less"]').before(markup);
        }
    }
};

/**
 * @description Attribute toggle function
 * @param  {String} attr    Attribute Name
 * @param  {String} val     Value to be matched
 * @param  {String} val2    Value to be replaced with
 */
$.fn.toggleAttr = function(attr, val, val2) {
    return this.each(function() {
        var self = $(this);
        if (self.attr(attr) == val)
            self.attr(attr, val2);
        else
            self.attr(attr, val);
    });
};


/**
 * A function to add data attributes to HTML about the user agent
 * @return {Null}
 */
$.browser_meta = function() {
    $('html')
        .attr('data-useragent', navigator.userAgent)
        .attr('data-platform', navigator.platform)
        .addClass(((!!('ontouchstart' in window) || !!('onmsgesturechange' in window)) ? ' touch' : ''));
};

/**
 * Cross browser file input controller
 * @return {Node} DOM Node
 */
$.file_input = function() {
    var elem = '.file-upload-control';

    return $(elem).each(function() {

        //Input value change function
        $(elem + ' :file').change(function() {
            var input = $(this),
                numFiles = input.get(0).files ? input.get(0).files.length : 1,
                label = input.val().replace(/\\/g, '/').replace(/.*\//, '');
            input.trigger('fileselect', [numFiles, label]);
        });

        //Button click function
        $(elem + ' .browse').click(function() {
            $(this).parents('.input-group').find(':file').click();
        });

        //File select function
        $(elem + ' :file').on('fileselect', function(event, numFiles, label) {
            var input = $(this).parents('.input-group').find(':text'),
                log = numFiles > 1 ? numFiles + ' files selected' : label;

            if (input.length) {
                input.val(log);
            } else {
                if (log) {
                    alert(log);
                }
            }
        });

    });
};

/**
 * @description Data Loader function
 * @param  {String}     action of the loader
 */

 ///////////////////////////////////////////////////
$.fn.loading = function(action) {

    return $(this).each(function() {
        var loadingText = ($(this).data('loading-text') === undefined) ? 'LOADING' : $(this).data('loading-text');

        var icon = ($(this).data('loading-image') === undefined) ? '' +
                    '<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"' +
                    'viewBox="0 0 14 14" enable-background="new 0 0 14 14" xml:space="preserve">' +
                    '<path class="circle" stroke-width="1.4" stroke-miterlimit="10" d="M6.534,0.748C7.546,0.683,8.578,0.836,9.508,1.25 c1.903,0.807,3.339,2.615,3.685,4.654c0.244,1.363,0.028,2.807-0.624,4.031c-0.851,1.635-2.458,2.852-4.266,3.222 c-1.189,0.25-2.45,0.152-3.583-0.289c-1.095-0.423-2.066-1.16-2.765-2.101C1.213,9.78,0.774,8.568,0.718,7.335 C0.634,5.866,1.094,4.372,1.993,3.207C3.064,1.788,4.76,0.867,6.534,0.748z"/>' +
                    '<path class="pulse-line" stroke-width="0.55" stroke-miterlimit="10" d="M12.602,7.006c-0.582-0.001-1.368-0.001-1.95,0 c-0.491,0.883-0.782,1.4-1.278,2.28C8.572,7.347,7.755,5.337,6.951,3.399c-0.586,1.29-1.338,3.017-1.923,4.307 c-1.235,0-2.38-0.002-3.615,0"/>' +
                    '</svg>' +
                    '<div class="signal"></div>'
                    :
                    '<img src="'+$(this).data('loading-image')+'" />';

        var html = '<div class="loading-animation">' +
            '<div class="logo">' +
            icon +
            '</div>' +
            '<p>' + loadingText + '</p>' +
            '</div>' +
            '<div class="loading-bg"></div>';

        if (action === 'show') {
            $(this).prepend(html).addClass('loading');
        }
        if (action === 'hide') {
            $(this).removeClass('loading');
            $('.loading-animation, .loading-bg', this).remove();
        }
    });

};

///////////////////////

/**
 * @description Auto resize icons and text on browser resize
 * @param  {Number}     Compression Ratio
 * @param  {Object}     Object containing the values to override defaults
 * @return {Node}       DOM Node
 */
$.fn.responsive_text = function(compress, options) {

    // Setup options
    var compressor = compress || 1,
        settings = $.extend({
            'minFontSize': Number.NEGATIVE_INFINITY,
            'maxFontSize': Number.POSITIVE_INFINITY
        }, options);

    return this.each(function() {

        //Cache object for performance
        var $this = $(this);

        //resize items based on the object width devided by the compressor
        var resizer = function() {
            $this.css('font-size', Math.max(Math.min($this.width() / (compressor * 10), parseFloat(settings.maxFontSize)), parseFloat(settings.minFontSize)));
        };

        //Init method
        resizer();

        //event bound to browser window to fire on window resize
        $(window).on('resize.fittext orientationchange.fittext', resizer);

    });

};



/**
 * @description Random background color generator for thumbs
 * @param  {range}      Color Range Value
 * @return {Node}       DOM Node
 */
$.fn.random_background_color = function(range) {

    if (!range) {
        range = 9;
    }

    return this.each(function() {

        var color = '#' + Math.random().toString(range).substr(-6);
        $(this).css('background', color);

    });

};

}(jQuery));
var responsiveTextRatio = 0.2,
    responsiveTextSleector = ".icon .text";


