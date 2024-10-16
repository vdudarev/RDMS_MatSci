// see https://habr.com/ru/articles/752268/

function Delete(obj) {
    var id = $(obj).parent("li[data-id]").attr("data-id");
    //console.log("Delete [id="+id+"]...");
    $(".dropzoneContainer button[type='submit']").prop("disabled", false);
}


// https://bbbootstrap.com/snippets/drag-and-drop-file-upload-choose-option-76752156
$(".dropzone input.file").on('change', function () {
    $(".dropzone").removeClass("droppable-hover");
    var files = $(this)[0].files;
    var filesCount = files.length;
    //console.log(files);
    var st = "";
    for (i = 0; i < files.length; i++) {
        console.log(files[i]);
        if (st != "")
            st += "<br>";
        st += files[i].name.split('\\').pop();
    }

    var textbox = $("div.list");

    if (filesCount === 1) {
        var fileName = $(this).val().split('\\').pop();
        textbox.html(fileName);
    } else {
        textbox.html('<u>' + filesCount + ' files selected</u>:<br>' + st);
    }
});

$(".dropzone").on('dragenter', function (event) {
    //console.log("...dragEnter..." + JSON.stringify(event.target));
    $(".dropzone").addClass("droppable-hover");
});
$(".dropzone").on('dragover', function (event) {
    //console.log("...dragover..." + JSON.stringify(event.target));
    $(".dropzone").addClass("droppable-hover");
});
$(".dropzone").on('dragleave', function (event) {
    //console.log("...dragleave..." + JSON.stringify(event.target));
    $(".dropzone").removeClass("droppable-hover");
});
