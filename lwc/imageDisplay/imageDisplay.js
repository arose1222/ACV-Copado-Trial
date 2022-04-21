import { LightningElement, api, track } from 'lwc';

export default class ImageDisplay extends LightningElement {
    @api hover = false;
    @api singleLink = '';
    @api imgList = [];
    @track displayList = [];
    @track selectedImage;
    @track openmodel = false;
    @api imageZoomEnabled = false;


    connectedCallback(){
        if(this.singleLink){
            // eslint-disable-next-line @lwc/lwc/no-inner-html
            this.displayList.push(this.createImageObject(this.singleLink));
        }
        else if(this.imgList){
            // eslint-disable-next-line @lwc/lwc/no-inner-html
            this.displayList = this.generateHTMLFromList(this.imgList);
        }
    }

    @api populateImageList(imageList){
        // eslint-disable-next-line @lwc/lwc/no-inner-html
        this.displayList = this.generateHTMLFromList(imageList);
    }

    generateHTMLFromList(imageList){
        var allHTML = [];
        imageList.forEach(i =>{
            allHTML.push(this.createImageObject(i));
        });
        return allHTML;
    }

    hoverOnLogic(event){
        if(this.hover){
            event.target.classList.remove('small');
            event.target.classList.add('large');
            event.target.classList.add('slds-popover');
            //event.target.classList.
        }
    }

    hoverOffLogic(event){
        if(this.hover){
            event.target.classList.remove('large');
            event.target.classList.remove('slds-popover');
            event.target.classList.add('small');
        }
    }

    async selectImage(event){
        this.displayList.forEach(im => {
            if(im.key === event.currentTarget.dataset.key){
                    this.selectedImage = im;
                    this.openmodel = true;
            }
        });
    }

    closeModel(){
        this.openmodel = false;
        this.selectedImage = null;
        this.imageZoomEnabled = false;
    }

    createImageObject(imageLink){
        var newImage = {
            link : imageLink,
            key : this.createUUID()
        }
        return newImage;
    }

    createUUID() {
        var dt = new Date().getTime();
        var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            var r = (dt + Math.random()*16)%16 | 0;
            dt = Math.floor(dt/16);
            return (c === 'x' ? r :(r&0x3|0x8)).toString(16);
        });
        return uuid;
    }

    enableImgZoom(){
        var lens, img;
        if(this.imageZoomEnabled){
            img = this.template.querySelector('[data-id="mainImg"]');
            lens = document.createElement("DIV");
            lens.setAttribute("class", "img-zoom-lens");
            lens.setAttribute("class", "slds-popover");
            lens.setAttribute("data-id", "imgLens");
            img.parentElement.insertBefore(lens, img);
            this.imageZoom();
        }
        else{
            lens = this.template.querySelector('[data-id="mainImg"]');
            lens.parentNode.removeChild(lens);
        }
    }

    hoverImgZoom(event){
        if(this.imageZoomEnabled){
            this.imageZoom(event.target.dataset.targetId);
        }
    }

    imageZoom() {
        var img, lens, cx, cy;
        img = this.template.querySelector('[data-id="mainImg"]');
        /* Create lens: */
        lens = this.template.querySelector('[data-id="imgLens"]');
        /* Insert lens: */
        /* Calculate the ratio between result DIV and lens: */
        cx = lens.offsetWidth / lens.offsetWidth;
        cy = lens.offsetHeight / lens.offsetHeight;
        /* Set background properties for the result DIV */
        lens.style.backgroundImage = "url('" + img.src + "')";
        lens.style.backgroundSize = (img.width * cx) + "px " + (img.height * cy) + "px";
        /* Execute a function when someone moves the cursor over the image, or the lens: */
        lens.addEventListener("mousemove", moveLens);
        img.addEventListener("mousemove", moveLens);
        /* And also for touch screens: */
        lens.addEventListener("touchmove", moveLens);
        img.addEventListener("touchmove", moveLens);
        function moveLens(e) {
          var pos, x, y;
          /* Prevent any other actions that may occur when moving over the image */
          e.preventDefault();
          /* Get the cursor's x and y positions: */
          pos = getCursorPos(e);
          /* Calculate the position of the lens: */
          x = pos.x - (lens.offsetWidth / 2);
          y = pos.y - (lens.offsetHeight / 2);
          /* Prevent the lens from being positioned outside the image: */
          if (x > img.width - lens.offsetWidth) {x = img.width - lens.offsetWidth;}
          if (x < 0) {x = 0;}
          if (y > img.height - lens.offsetHeight) {y = img.height - lens.offsetHeight;}
          if (y < 0) {y = 0;}
          /* Set the position of the lens: */
          lens.style.left = x + "px";
          lens.style.top = y + "px";
          /* Display what the lens "sees": */
          lens.style.backgroundPosition = "-" + (x * cx) + "px -" + (y * cy) + "px";
        }
        function getCursorPos(e) {
          var a, x = 0, y = 0;
          e = e || window.event;
          /* Get the x and y positions of the image: */
          a = img.getBoundingClientRect();
          /* Calculate the cursor's x and y coordinates, relative to the image: */
          x = e.pageX - a.left;
          y = e.pageY - a.top;
          /* Consider any page scrolling: */
          x = x - window.pageXOffset;
          y = y - window.pageYOffset;
          return {x : x, y : y};
        }
      }
}