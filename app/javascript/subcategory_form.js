document.addEventListener('DOMContentLoaded', function () {
  previewImages(document.getElementById('subcategory_photos'));
  loadSavedOrder();

  var previewContainer = document.getElementById('image-preview-container');
  previewContainer.addEventListener('dragenter', allowDrop);
  previewContainer.addEventListener('dragover', allowDrop);
  previewContainer.addEventListener('drop', drop);

  // Attach event listener to form submit to include orientation data
  document.getElementById('subcategory-form').addEventListener('submit', function () {
    var orientationData = {};
    Array.from(previewContainer.children).forEach(function (child, index) {
      var radioButtons = child.querySelectorAll('input[type="radio"]');
      radioButtons.forEach(function (radio) {
        if (radio.checked) {
          orientationData[index] = radio.value;
        }
      });
    });
    document.getElementById('orientation-data-field').value = JSON.stringify(orientationData);
  });
});

function previewImages(input) {
  var previewContainer = document.getElementById('image-preview-container');
  previewContainer.innerHTML = '';

  if (input.files) {
    for (var i = 0; i < input.files.length; i++) {
      var reader = new FileReader();

      reader.onload = function (e) {
        var container = document.createElement('div');
        container.classList.add('image-container');

        var img = document.createElement('img');
        img.src = e.target.result;
        img.classList.add('img-thumbnail', 'draggable');
        img.setAttribute('draggable', 'true');
        img.addEventListener('dragstart', handleDragStart);

        var radioContainer = document.createElement('div');
        radioContainer.classList.add('radio-container');

        var landscapeLabel = document.createElement('label');
        landscapeLabel.textContent = 'Landscape';
        var landscapeRadio = document.createElement('input');
        landscapeRadio.type = 'radio';
        landscapeRadio.name = 'orientation_' + i;
        landscapeRadio.value = 'landscape';
        landscapeRadio.dataset.index = i; // Add dataset index for association
        landscapeLabel.appendChild(landscapeRadio);

        var portraitLabel = document.createElement('label');
        portraitLabel.textContent = 'Portrait';
        var portraitRadio = document.createElement('input');
        portraitRadio.type = 'radio';
        portraitRadio.name = 'orientation_' + i;
        portraitRadio.value = 'portrait';
        portraitRadio.dataset.index = i; // Add dataset index for association
        portraitLabel.appendChild(portraitRadio);

        radioContainer.appendChild(landscapeLabel);
        radioContainer.appendChild(portraitLabel);

        container.appendChild(img);
        container.appendChild(radioContainer);

        previewContainer.appendChild(container);
      };

      reader.readAsDataURL(input.files[i]);
    }

    saveOrder();
  }
}

function handleDragStart(e) {
  e.dataTransfer.setData('text/plain', e.target.src);
  e.target.style.opacity = '0.5';
}

function allowDrop(e) {
  e.preventDefault();
}

function drop(e) {
  e.preventDefault();
  var previewContainer = document.getElementById('image-preview-container');
  var data = e.dataTransfer.getData('text/plain');

  var img = document.createElement('img');
  img.src = data;
  img.classList.add('img-thumbnail', 'draggable');
  img.setAttribute('draggable', 'true');
  img.addEventListener('dragstart', handleDragStart);

  var container = document.createElement('div');
  container.classList.add('image-container');

  var radioContainer = document.createElement('div');
  radioContainer.classList.add('radio-container');

  var landscapeIcon = document.createElement('i');
  landscapeIcon.classList.add('fas', 'fa-panorama');

  var landscapeLabel = document.createElement('label');
  landscapeLabel.appendChild(landscapeIcon);
  landscapeLabel.appendChild(document.createTextNode(' Landscape'));

  var landscapeRadio = document.createElement('input');
  landscapeRadio.type = 'radio';
  landscapeRadio.name = 'orientation_' + previewContainer.children.length;
  landscapeRadio.value = 'landscape';
  landscapeLabel.appendChild(landscapeRadio);

  var portraitIcon = document.createElement('i');
  portraitIcon.classList.add('fas', 'fa-image-portrait');

  var portraitLabel = document.createElement('label');
  portraitLabel.appendChild(portraitIcon);
  portraitLabel.appendChild(document.createTextNode(' Portrait'));

  var portraitRadio = document.createElement('input');
  portraitRadio.type = 'radio';
  portraitRadio.name = 'orientation_' + previewContainer.children.length;
  portraitRadio.value = 'portrait';
  portraitLabel.appendChild(portraitRadio);

  radioContainer.appendChild(landscapeLabel);
  radioContainer.appendChild(portraitLabel);

  container.appendChild(img);
  container.appendChild(radioContainer);

  // Insert the container before the last child of previewContainer
  previewContainer.insertBefore(container, previewContainer.lastElementChild);

  saveOrder();
}



function saveOrder() {
  var previewContainer = document.getElementById('image-preview-container');
  var order = Array.from(previewContainer.children).map(function (child) {
    return child.querySelector('img').src;
  });

  try {
    localStorage.setItem('imageOrder', JSON.stringify(order));
  } catch (e) {
    console.error('Error saving order to localStorage:', e);
  }
}

function loadSavedOrder() {
  var previewContainer = document.getElementById('image-preview-container');
  var savedOrder = localStorage.getItem('imageOrder');

  if (savedOrder) {
    try {
      savedOrder = JSON.parse(savedOrder);

      savedOrder.forEach(function (src, index) {
        var container = document.createElement('div');
        container.classList.add('image-container');

        var img = document.createElement('img');
        img.src = src;
        img.classList.add('img-thumbnail', 'draggable');
        img.setAttribute('draggable', 'true');
        img.addEventListener('dragstart', handleDragStart);

        var radioContainer = document.createElement('div');
        radioContainer.classList.add('radio-container');

        var landscapeLabel = document.createElement('label');
        landscapeLabel.textContent = 'Landscape';
        var landscapeRadio = document.createElement('input');
        landscapeRadio.type = 'radio';
        landscapeRadio.name = 'orientation_' + index;
        landscapeRadio.value = 'landscape';
        landscapeLabel.appendChild(landscapeRadio);

        var portraitLabel = document.createElement('label');
        portraitLabel.textContent = 'Portrait';
        var portraitRadio = document.createElement('input');
        portraitRadio.type = 'radio';
        portraitRadio.name = 'orientation_' + index;
        portraitRadio.value = 'portrait';
        portraitLabel.appendChild(portraitRadio);

        radioContainer.appendChild(landscapeLabel);
        radioContainer.appendChild(portraitLabel);

        container.appendChild(img);
        container.appendChild(radioContainer);

        previewContainer.appendChild(container);
      });
    } catch (e) {
      console.error('Error loading order from localStorage:', e);
    }
  }
}
