// // app/assets/javascripts/photo_upload.js
// // app/assets/javascripts/photo_upload.js
// // app/javascript/photo_upload.js
// // import Dropzone from "dropzone";
// import { Dropzone } from "dropzone";
// import { Sortable } from "sortablejs";

// // import Sortable from "sortablejs";
// // import 'packery'


// document.addEventListener("DOMContentLoaded", function () {
//   // Initialize Dropzone
//   Dropzone.options.photoDropzone = {
//     paramName: "subcategory[photos][]",
//     maxFilesize: 5, // Set your max file size
//     addRemoveLinks: true,
//     init: function () {
//       this.on("addedfile", function (file) {
//         // Add the file to the preview container
//         $("#photo-preview").append('<img src="' + URL.createObjectURL(file) + '" class="img-thumbnail" />')
//       })

//       // Initialize Sortable
//       new Sortable(document.getElementById("photo-preview"), {
//         animation: 150,
//         ghostClass: "bg-light",
//       })
//     },
//   }
// })
