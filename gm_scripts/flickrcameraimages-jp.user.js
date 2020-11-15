// ==UserScript==
// @name          Flickr Camera Images (Amazon.co.jp)
// @namespace     http://blog.bulknews.net/
// @description   Adds camera images from Amazon to Flickr "More properties" Exif pages
// @include       http://www.flickr.com/photo_exif*
// @include       http://flickr.com/photo_exif*
// ==/UserScript==

// This GM script is based on http://www.onfocus.com/flickrcameraimages.user.js
// hacked to work with Amazon.co.jp Web Services

(

function()
{

var head, style;
head = document.getElementsByTagName('head')[0];
if (!head) { return; }
style = document.createElement('style');
style.type = 'text/css';
style.innerHTML = '#cam { border:solid #fff 1px;padding:5px; } #GoodStuff div a:hover {color:#fff;background:#fff;}';
head.appendChild(style);

var amazonurl = 'http://webservices.amazon.co.jp/onca/xml?Service=AWSECommerceService&AWSAccessKeyId=1HHYYPKP49SW3PQQM1G2';
var thisInbox = document.getElementById('Inbox');
var thisCameraNode = thisInbox.childNodes[1].childNodes[0].childNodes[3];
var thisCamera = thisCameraNode.textContent;

        if (!GM_xmlhttpRequest) {
                alert('Giving up :( Cannot create an XMLHTTP instance');
                return false;
        }
        amazonurl = amazonurl+'&Operation=ItemSearch&Keywords='+thisCamera+'&SearchIndex=Electronics&ResponseGroup=Images&MerchantId=All&BrowseNode=3371371';
        GM_xmlhttpRequest(
        {
                method: 'GET',
                url: amazonurl,
                headers: {
                'User-agent': 'Mozilla/4.0 (compatible) Greasemonkey/0.3',
                'Accept': 'application/atom+xml,application/xml,text/xml',
                },
                onload: function(responseDetails) {
                        var resultxml = responseDetails.responseText.replace(
                        /<\?xml version="1.0" encoding="UTF-8"\?>/ ,'');
                        try{
                        var resultdom = new XML(resultxml);
                        }catch(ex){
                                GM_log(ex.toString());
                        }
                        var amzns = new Namespace('http://webservices.amazon.com/AWSECommerceService/2005-10-05');
                        var imagenodes = resultdom..amzns::Item.amzns::MediumImage.amzns::URL;
                        var heightnodes = resultdom..amzns::Item.amzns::MediumImage.amzns::Height;
                        var widthnodes = resultdom..amzns::Item.amzns::MediumImage.amzns::Width;
                        var asins = resultdom..amzns::Item.amzns::ASIN;
                        if (imagenodes.length() > 0) {
                                var divElement = document.createElement('div');
                                var gs = document.getElementById('Inbox');
                                gs.parentNode.insertBefore(divElement,gs);
                                imageElement = document.createElement('img');
                                imageElement.src = imagenodes[0].text();
                                imageElement.width = widthnodes[0].text();
                                imageElement.height = heightnodes[0].text();
                                imageElement.border = '0';
                                imageElement.id = 'cam';
                                aElement = document.createElement('a');
                                aElement.href = 'http://www.amazon.co.jp/exec/obidos/ASIN/'+asins[0].text()+'/ref=nosim/bulknews-22';
                                aElement.id = 'camlink';
                                aElement.appendChild(imageElement);
                                divElement.appendChild(aElement);
                        } else {
                                var googLink = 'http://www.google.co.jp/search?q='+escape(thisCamera);
                                thisCameraNode.innerHTML = '<a href='+googLink+'>'+thisCamera+'</a>';
                        }
                }
        });
}
)();
