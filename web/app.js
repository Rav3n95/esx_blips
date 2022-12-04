const container = document.getElementById("container");
const notify = document.getElementById("notify");
const dataArray = [];

function updateData(data) {
  data.value.forEach((element) => {
    if (!dataArray.find((oldElement) => element == oldElement.name)) {
      dataArray.push({ name: element, checked: true });
    }
  });

  container.innerHTML = `
        <div id='title'>${data.title}</div>
        <div id='content'></div>`;

  dataArray.forEach((element) => {
    temp = document.createElement("div");
    temp.id = element;
    temp.className = "content";
    temp.innerHTML = `${element.name}
            <label class="switch">
            <input data= ${element.name} type="checkbox" ${
      element.checked ? "checked" : ""
    }>
            <div class="slider round"></div>
            </label>
        `;

    document.getElementById("content").appendChild(temp);
  });
}

const fetchPlus = (url, options = {}, retries) =>
  fetch(url, options)
    .then(async (res) => {
      if (res.ok) {
        return res.json();
      }
      if (retries > 0) {
        await new Promise((r) => setTimeout(r, 1000));
        return fetchPlus(url, options, retries - 1);
      }
      throw new Error(res.status);
    })
    .catch(async (error) => {
      if (retries > 0) {
        await new Promise((r) => setTimeout(r, 1000));
        return fetchPlus(url, options, retries - 1);
      }
    });

fetchPlus(
  `https://${GetParentResourceName()}/documentReady`,
  {
    method: "POST",
  },
  5
).then((data) => {
  updateData(data);

  window.addEventListener("message", function (event) {
    const data = event.data;

    switch (data.type) {
      case "showNotify":
        if (data.value) {
          notify.style.display = "block";
          notify.innerHTML = data.text
        } else {
          notify.style.display = "none";
        }
        break;
      case "showMenu":
        if (data.value) {
          container.style.display = "block";
        } else {
          container.style.display = "none";
        }
        break;
      case "updateData":
        updateData(data);
        break;
      case "updateCategoryState":
        for (category of dataArray) {
          if (data.name == data.cat) {
            dataArray.checked = data.value;
          }
        }

        break;
    }
  });

  window.addEventListener("change", function (event) {
    const obj = event.target;
    dataArray.forEach((element) => {
      if (element.name == obj.getAttribute("data")) {
        element.checked = obj.checked;
      }
    });

    fetchPlus(`https://${GetParentResourceName()}/action`, {
      method: "POST",
      body: JSON.stringify({
        target: obj.getAttribute("data"),
        checked: obj.checked,
      }),
    }, 5);
  });

  document.onkeyup = function (data) {
    if (data.which == 27) {
      fetchPlus(
        `https://${GetParentResourceName()}/close`,
        {
          method: "POST",
        },
        5
      );
    }
  };
});
