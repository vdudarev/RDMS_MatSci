// Highlight selected elements
function HighlightSelectedElements(selectedElementsArr) {
    $(".Mendeleev .element").removeClass("selected");
    for (var i = 0; i < selectedElementsArr.length; i++) {
        $(".Mendeleev .element[data-name='" + selectedElementsArr[i] + "']").toggleClass("selected"); // поменяли класс selected
    }
}

// get selected elements from UI
function Mendeleev_doMain_GetSelectedElements() {
    var arr = [];
    $(".Mendeleev .selected").each(function () {
        //arr.push($(this).children(".name").text());
        arr.push($(this).attr("data-name"));
    });
    arr.sort();
    return arr;
}

function Mendeleev_showSystemInfo(selectedElements) {
    if (selectedElements.length > 0) {
        $(".selectedElementsResult .inactive").hide();
        $(".Mendeleev .selectedSystem").html(selectedElements);
    } else {
        $(".selectedElementsResult .inactive").show();
        $(".Mendeleev .selectedSystem").html("");
    }
}

function Mendeleev_doInit(initObj) {
    var initSelectedElements = initObj.system;
    var arrSelectedSystem = initSelectedElements.split("-");
    // highlight selected elements by arrSelectedSystem
    HighlightSelectedElements(arrSelectedSystem);
    Mendeleev_showSystemInfo(initSelectedElements);
}

// on elements change in Periodic Table
function Mendeleev_doMain() {
    var arrSelectedSystem = Mendeleev_doMain_GetSelectedElements();
    var st = arrSelectedSystem.join("-");
    $("#Elements").val(st);
    Mendeleev_showSystemInfo(st);
    UpdateCompositionTable(arrSelectedSystem);
}

function Mendeleev_showTable_init() {
    $(".btnshowperiodictable").click(function () {   // add to the top
        Mendeleev_showTable();
    });
}
function Mendeleev_showTable() {
    Mendeleev_doInit({ "system": $("#Elements").val() });
    ShowModal("myModalMendeleev");
}


// press delete buttons in compound table
function DeleteCompoundTableElement(obj) {
    var row = $(obj).closest('tr');
    var el = row.attr("data-element");
    row.remove();
    var system = $("#Elements").val();
    system = ('-' + system + '-').replace('-' + el + '-', '-');
    if (system.length > 2)
        system = system.substring(1, system.length - 1);
    else
        system = "";
    $("#Elements").val(system);
}

function UpdateCompositionTableBySystem() {
    var arr = $("#Elements").val().split("-");
    UpdateCompositionTable(arr);
}

function UpdateCompositionTable(arrSelectedSystem) {
    if (document.getElementById("compoundTableBody") == null)
        return;
    // remove Rows that are not in chemical system
    $("#compoundTableBody>tr").each(function () {
        var el = $(this).attr("data-element");
        if (el != "" && !arrSelectedSystem.includes(el))
            $(this).remove();
    });
    // add non-existent Rows
    for (i = 0; i < arrSelectedSystem.length; i++) {
        if ($("#compoundTableBody>tr[data-element='" + arrSelectedSystem[i] + "']").length > 0)
            continue;
        var html = $("#compoundTableBody>tr[data-element='']").prop('outerHTML');
        //console.log("PRE: " + html);
        html = html.replace('<tr data-element="">', '<tr data-element="' + arrSelectedSystem[i] + '">');
        html = html.replace('<input type="hidden" name="element" value="">', arrSelectedSystem[i] + '<input type="hidden" name="element" value="' + arrSelectedSystem[i] + '">');
        html = html.replace('name="ValueAbsolute"', 'name="' + arrSelectedSystem[i] + '_ValueAbsolute"');
        html = html.replace('name="ValuePercent"', 'name="' + arrSelectedSystem[i] + '_ValuePercent"');
        //console.log("POST: " + html);
        $("#compoundTableBody").append(html);
    }
}

function MakeSortableTable() {
    var $tableBody = $('#compoundTable>tbody');
    //console.log("MakeSortableTable");
    Sortable.create(
        $tableBody[0],
        {
            animation: 150,
            scroll: true,
            handle: '.drag-handler',
            onEnd: function () {
                // console.log("MakeSortableTable - onEnd");
                // console.log('More see in https://github.com/RubaXa/Sortable');
            }
        }
    );
}

$(document).ready(function () {
    $(".Mendeleev .element").click(function () { // при клике на элементе
        $(this).toggleClass("selected"); // поменяли класс selected
        Mendeleev_doMain();
    });
    if (document.getElementById("Elements") != null) {
        UpdateCompositionTable($("#Elements").val().split("-"));
    }
    if (document.getElementById("compoundTable") != null) {
        MakeSortableTable();
    }

    //ClassicEditor
    //    .create(document.querySelector('#ObjectDescription'))
    //    .catch(error => {
    //        console.error(error);
    //    });
});

