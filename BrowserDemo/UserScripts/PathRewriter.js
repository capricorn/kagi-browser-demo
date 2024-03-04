let images = document.getElementsByTagName('img');

/*
for (var img of images) {
    console.log('original src: ' + img.src);
    if (img.src.startsWith('file://')) {
        //img.src = '.' + img.src;
        img.src = '.' + img.src.slice(7);
        console.log("Rewrote image source: " + img.src);
    }
}
 */

console.log("Rewrote images");
