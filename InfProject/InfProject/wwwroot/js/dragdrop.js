// "Search" button
function DoObjectSearch() {
    $('#listContainer').html("<p><img src='/i/loaderLight.gif' alt='wait, please' align='center' /></p>");
    var query = document.getElementById('oname').value;
    var typeId = $('#otypeId').val();
    var queryData = { "query": query, "typeId": parseInt(typeId), "objectId": app.objectId };
    $.ajax({
        type: "POST",
        url: "/ajax/searchobjectlist",
        data: queryData,
        dataType: "json",
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            $('#listContainer').html(html);
            $('#list').html("<li class=\"list-group-item disabled\" aria-disabled=\"true\">ajax error (textStatus" + textStatus + "errorThrown: " + errorThrown + ")</li>");
        },
        success: function (data, status) {
            // <a href="#asf1" data-id="id1">test 1</a>
            // $('#listContainer').html("Length = " + data.length + JSON.stringify(data));
            console.log(JSON.stringify(queryData) + "\r\n: " + JSON.stringify(data));
            var html = "";
            if (data.length > 0) {
                for (i = 0; i < data.length; i++) {
                    html += "<li class=\"list-group-item\" title=\"Drag me from here to the Drag&Drop box\"><a href=\"#" + data[i].objectId + "\" data-id=\"" + data[i].objectId + "\">" + data[i].objectName + " [" + GetTypeName(data[i].typeId) + "]</a></li>";
                }
            } else {
                html = "<li class=\"list-group-item disabled\" aria-disabled=\"true\">Nothing found (query: " + query + "; type: " + $("#otypeId option:selected").text() + ")</li>";
            }
            $('#listContainer').html(html);
            // $('#listTemplate').tmpl(data).appendTo('#listContainer');
            // $('#listContainer').html(data.sampleListHtml);
            // initDataTable();
        }
    });

}

// "Delece" (cross) button
function Delete(obj) {
    var id = $(obj).parent("li[data-id]").attr("data-id");
    //console.log("Delete [id="+id+"]...");
    $(".dropzoneContainer button[type='submit']").prop("disabled", false);
}

// "Save" button
function AssocSave() {
    let i = 0;
    // const linkTypeObjectId = $("#linkTypeObjectId").val();
    queryData = { "ObjectId": app.objectId, /*"LinkTypeObjectId": linkTypeObjectId,*/ Links: [] };
    $(".associated-content li[data-id]").each(function (obj) {
        let id = $(this).attr("data-id");
        let linkTypeObjectId = $(this).attr("data-linkTypeObjectId");
        queryData.Links.push({ "LinkedObjectId": id, "SortCode": i += 10, "LinkTypeObjectId": linkTypeObjectId });
    });
    let requestData = JSON.stringify(queryData);
    // console.log("AssocSave: queryData=" + requestData);
    $.ajax({
        type: "POST",
        url: "/adminobject/linksupdate",
        contentType: "application/json",
        data: requestData,
        dataType: "json",
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            $('.dropzoneContainer .err').html("AssocSave error textStatus=" + textStatus + ", errorThrown=" + errorThrown);
        },
        success: function (data, status) {
            if ('error' in data) {
                alert(data.error);  // TODO make it fancy!
                return;
            }
            // console.log("AssocSave(Length=" + data.length + "): " + JSON.stringify(data));
            $(".associated-content li").removeClass("alert-warning").addClass("alert-success");
            $(".dropzoneContainer button[type='submit']").prop("disabled", true);
        }
    });
}

//const dropzone = document.querySelectorAll(".dropzone");
document.querySelectorAll(".dropzone, .dropzone *").forEach(elem => {
    elem.addEventListener("dragenter", function (event) {  // Fires when a dragged item enters a valid drop target
        console.log("...dragEnter..." + JSON.stringify(event.target));
        if (!event.target.classList.contains("dropped")) {
            event.target.classList.add("droppable-hover");
        }
    });
    elem.addEventListener("dragover", function (event) {    // Fires when a dragged item is being dragged over a valid drop target, repeatedly while the draggable item is within the drop zone
        console.log("...dragOver...");
        if (!event.target.classList.contains("dropped")) {
            event.preventDefault(); // Prevent default to allow drop
        }
    });
    elem.addEventListener("dragleave", function (event) {    // Fires when a dragged item leaves a valid drop target
        console.log("...dragLeave...");
        if (!event.target.classList.contains("dropped")) {
            event.target.classList.remove("droppable-hover");
        }
    });
    elem.addEventListener("drop", function (event) { // Fires when an item is dropped on a valid drop target
        function err(msg) {
            if (msg == null) {
                $(".dropzoneContainer .err").html("");
                return;
            }
            $(".dropzoneContainer .err").html('<div class="alert alert-danger alert-dismissible" role="alert">' + msg + '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button></div>')
        }
        err(null);
        console.log("...drop: " + JSON.stringify(event) + "; event.target=" + JSON.stringify(event.target) + "; event.dataTransfer=" + JSON.stringify(event.dataTransfer));
        event.preventDefault(); // This is in order to prevent the browser default handling of the data
        event.target.classList.remove("droppable-hover");

        const linkTypeObjectId = $("#linkTypeObjectId").val();
        const draggableElementData = JSON.parse(event.dataTransfer.getData("data")); // Get the dragged data. This method will return any data that was set to the same type in the setData() method
        // check
        if ($(".associated-content li[data-id='" + draggableElementData.id + "']").length > 0) {
            err('Associated list already contains the element with id=' + draggableElementData.id);
            return;
        }
        // add alert-warning
        if (linkTypeObjectId != 0) {
            const linkTypeName = $("#linkTypeObjectId option[value='" + linkTypeObjectId + "']").text();
            $("#associated-content").append('<li class="alert alert-warning alert-dismissible" role="alert" data-linkTypeObjectId="' + linkTypeObjectId + '" data-id="' + draggableElementData.id + '">' + draggableElementData.text + '<small><i class="bi bi-link ms-5 me-1"></i>' + linkTypeName + '</small><button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close" onclick="Delete(this)"></button></li>');
        }
        else {
            $("#associated-content").append('<li class="alert alert-warning alert-dismissible" role="alert" data-linkTypeObjectId="' + linkTypeObjectId + '" data-id="' + draggableElementData.id + '">' + draggableElementData.text + '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close" onclick="Delete(this)"></button></li>');
        }
        $(".dropzoneContainer button[type='submit']").prop("disabled", false);
        //const droppableElementData = event.target.getAttribute("data-draggable-id");
        //const isCorrectMatching = draggableElementData === droppableElementData;
        //if (isCorrectMatching) {
        //    const draggableElement = document.getElementById(draggableElementData);
        //    event.target.classList.add("dropped");
        //    event.target.style.backgroundColor = window.getComputedStyle(draggableElement).color;
        //    draggableElement.classList.add("dragged");
        //    draggableElement.setAttribute("draggable", "false");
        //    event.target.insertAdjacentHTML("afterbegin", `<i class="fas fa-${draggableElementData}"></i>`);
        //}
    });
});

document.querySelectorAll(".fordrag").forEach(elem => {
    elem.addEventListener("dragstart", function (event) {  // Fires as soon as the user starts dragging an item - This is where we can define the drag data
        console.log("...dragStart..." + JSON.stringify(event));
        event.dataTransfer.setData("data", JSON.stringify({
            "id": event.target.getAttribute("data-id"),
            "text": event.target.innerText
        })); // or "text/plain" but just "text" would also be fine since we are not setting any other type/format for data value
    });
    // elem.addEventListener("drag", drag); // Fires when a dragged item (element or text selection) is dragged
    // elem.addEventListener("dragend", dragEnd); // Fires when a drag operation ends (such as releasing a mouse button or hitting the Esc key) - After the dragend event, the drag and drop operation is complete
});