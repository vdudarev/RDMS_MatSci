// Render elements available
function RenderPeriodicTableAvailableElements(availableElementsArr) {
    // console.log("RenderPeriodicTableAvailableElements: " + JSON.stringify(availableElementsArr));
    $(".Mendeleev .element").addClass("inactive");
    for (var i = 0; i < availableElementsArr.length; i++) {
        $(".Mendeleev .element[data-name='" + availableElementsArr[i] + "']").removeClass("inactive");
    }
}

// Highlight selected elements
function HighlightSelectedElements(compositionItemArr) {
    $(".Mendeleev .element").removeClass("selected");
    for (var i = 0; i < compositionItemArr.length; i++) {
        $(".Mendeleev .element[data-name='" + compositionItemArr[i].ElementName + "']").toggleClass("selected"); // поменяли класс selected
    }
    UpdateSearchCompositionTable(compositionItemArr);
}

// set text in input (SearchPhrase)
function SetSelectedSearchPhrase(searchPhrase) {
    $('#SearchPhrase').val(searchPhrase);
}
// get text in input (SearchPhrase)
function GetSearchPhrase() {
    return $('#SearchPhrase').val();
}

function selectElement(id, valueToSelect) {
    let element = document.getElementById(id);
    element.value = valueToSelect;
}

// set text in input (CreatedByUser)
function SetTypeId(valueToSelect) {
    selectElement('TypeId', valueToSelect);
}
// get text in input (CreatedByUser)
function GetTypeId() {
    var ret = $('#TypeId').val() ?? 0;
    return ret;
}



// set text in input (CreatedByUser)
function SetCreatedByUser(valueToSelect) {
    selectElement('CreatedByUser', valueToSelect);
}
// get text in input (CreatedByUser)
function GetCreatedByUser() {
    var ret = $('#CreatedByUser').val() ?? 0;
    return ret;
}
function RenderUsersAvailable(availablePersonsArr) {
    var curValue = GetCreatedByUser();
    // console.log("RenderUsersAvailable: " + JSON.stringify(availablePersonsArr));
    var st = "<option></option>\r\n";
    for (i = 0; i < availablePersonsArr.length; i++) {
        st += "<option value=\"" + availablePersonsArr[i].id + "\">" + availablePersonsArr[i].name + "</option>\r\n";
    }
    $('#CreatedByUser').html(st);
    SetCreatedByUser(curValue);
}

// set text in input (CreatedMin)
function SetSelectedCreatedMin(date) {
    $('#CreatedMin').val(date);
}
// get text in input (CreatedMin)
function GetCreatedMin() {
    var ret = $('#CreatedMin').val();
    return ret;
}

// set text in input (CreatedMax)
function SetSelectedCreatedMax(date) {
    $('#CreatedMax').val(date);
}
// get text in input (CreatedMax)
function GetCreatedMax() {
    var ret = $('#CreatedMax').val();
    return ret;
}

// ObjectId, ExternalId
function SetInt(id, value) {
    if (value == 0)
        value = "";
    $('#' + id).val(value);
}
function GetInt(id) {
    var ret = $('#' + id).val();
    return ret;
}


// Updates Samples list according to selected elements from app object
function UpdateFilteredList() {
    //console.log("UpdateFilteredList");
    //console.log(app.filter);
    $('#listContainer').html("<p><img src='/i/loaderLight.gif' alt='wait, please' align='center' /></p>");
    $.ajax({
        type: "POST",
        url: "/search/search",
        data: app.filter,
        dataType: "json",
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            $('#listContainer').html("ajax error textStatus=" + textStatus + ", errorThrown=" + errorThrown);
        },
        success: function (data, status) {
            RenderPeriodicTableAvailableElements(data.availableElements);
            if (isActiveFilter(app.filter)) {
                RenderUsersAvailable(data.availablePersons);
            }
            else {
                RenderUsersAvailable(app.initPersonsArr);
            }
            if (data.objectCount > 0) {
                $('#listContainer').html(data.objectListHtml);
                const el = document.getElementById('nav-enrich');
                if (el != null && app.filter.PropertyItems.length>0) {
                    el.classList.remove("d-none");
                }
                initDataTable();
            } else {
                $('#listContainer').html("<p>Empty search result</p>");
            }
        }
    });
}

/// for beautiful resizing of screen (to make a vertical scroll to avoid horizontal shift)
function Mendeleev_myResize() {
    let h = 0; // $("#headerOuter").height() + $("#footerOuter").height() + 2/* BORDER */;
    let wh = $(window).height();
    let bh = $("body").css("min-height", "").height();
    // console.log("h = " + h + ", wh = " + wh + ", bh = " + bh);
    if (bh <= wh - h) {
        $("body").css("min-height", (wh - h + 1) + "px");
    }
}

// get selected elements from UI + composition
function Mendeleev_doMain_GetCompositionItems() {
    let arr = [];
    $(".Mendeleev .selected").each(function () {
        let elName = $(this).attr("data-name");
        let absMin = $("#SearchCompoundTableBody tr[data-element='" + elName + "'] input[name='" + elName + "_ValueAbsoluteMin']").val();
        let absMax = $("#SearchCompoundTableBody tr[data-element='" + elName + "'] input[name='" + elName + "_ValueAbsoluteMax']").val();
        let pctMin = $("#SearchCompoundTableBody tr[data-element='" + elName + "'] input[name='" + elName + "_ValuePercentMin']").val();
        let pctMax = $("#SearchCompoundTableBody tr[data-element='" + elName + "'] input[name='" + elName + "_ValuePercentMax']").val();
        let obj = new FilterCompositionItem(elName, absMin, absMax, pctMin, pctMax);
//console.log("Mendeleev_doMain_GetCompositionItems: " + JSON.stringify(obj));
        arr.push(obj);
    });
    arr.sort((a, b) => (a.ElementName > b.ElementName) ? 1 : -1);
    return arr;
}

// get properties
function Mendeleev_doMain_GetPropertyItems() {
    let arr = [];
    $("#FilterProperties div.rowitem").each(function () {
        let name = $(this).find("input[name='PropertyName']").val();
        let type = $(this).find("select[name='PropertyType']").val();
        let propNameObj = app.propertyNames.find(element => element.type == type && element.nameShort == name);
        if (typeof propNameObj !== "undefined") {
            name = propNameObj.name;
//console.log(`Mendeleev_doMain_GetPropertyItems: replaced ${propNameObj.nameShort} => ${propNameObj.name}`);
        }
        let item = new FilterPropertyItem(
            name,
            type,
            $(this).find("input[name='ValueMin']").val(),
            $(this).find("input[name='ValueMax']").val(),
            $(this).find("input[name='ValueString']").val()
        );
        if (item.PropertyType != 'Float' && item.PropertyType != 'Int' && item.PropertyType != 'String' && item.PropertyType != 'BigString')
            return;
        if (item.PropertyName.length == 0)
            return;
        if (item.PropertyType == 'Float' || item.PropertyType == 'Int') {
            if (item.ValueMin.length == 0 && item.ValueMax.length == 0)
                return;
            item.ValueString = "";
        }
        if (item.PropertyType == 'String' || item.PropertyType == 'BigString') {
            if (item.ValueString.length == 0)
                return;
            item.ValueMin = "";
            item.ValueMax = $(this).find("select[name='StringCompare']").val();
            item.ValueMax = parseInt(item.ValueMax);    // NEW comparison for strings: 0 - equal; 1 - starts with; 2 - ends with; 3 - contains
            if (item.ValueMax < 0 || item.ValueMax > 3 || isNaN(item.ValueMax)) {
                item.ValueMax = 3;
            }
            item.ValueMax = item.ValueMax.toString();
        }
        arr.push(item);
    });
// console.log("Mendeleev_doMain_GetPropertyItems: " + JSON.stringify(arr));
    return arr;
}

// clear all and refresh
function Mendeleev_Clear(DoNotCallDoMain) {
    DoNotCallDoMain = typeof (DoNotCallDoMain) == undefined ? false : DoNotCallDoMain;
    HighlightSelectedElements([]);
    SetTypeId(0);
    SetSelectedSearchPhrase("");
    SetCreatedByUser("");
    SetSelectedCreatedMin("");
    SetSelectedCreatedMax("");
    SetInt("ObjectId", "");
    SetInt("ExternalId", "");
    if (!DoNotCallDoMain) {
        Mendeleev_doMain();
    }
}

/// main function to get selected elements and other stuff and send a query to DB
function Mendeleev_doMain() {
//console.log("Mendeleev_doMain_0: " + JSON.stringify(app.filter));
    app.filter.CompositionItems = Mendeleev_doMain_GetCompositionItems();
    app.filter.PropertyItems = Mendeleev_doMain_GetPropertyItems();
    app.filter.TypeId = GetTypeId();
    app.filter.SearchPhrase = GetSearchPhrase();
    app.filter.CreatedByUser = GetCreatedByUser();
    app.filter.CreatedMin = GetCreatedMin();
    app.filter.CreatedMax = GetCreatedMax();
    app.filter.ObjectId = GetInt("ObjectId");
    app.filter.ExternalId = GetInt("ExternalId");
    let arrElements = app.filter.CompositionItems.map(x => x.ElementName);
    UpdateSearchCompositionTable(app.filter.CompositionItems);
    var st = arrElements.join("-");
    $(".result").html("");
    var title = "", titleAdds = "", url = "/";
console.log("Mendeleev_doMain_2: " + JSON.stringify(app.filter));
// console.log("Mendeleev_doMain: app.filter.CompositionItems: " + JSON.stringify(app.filter.CompositionItems));
    if (isActiveFilter(app.filter)) { // filter is active
// console.log("Mendeleev_doMain: filter SET");
        titleAdds = "";
        if (arrElements.length > 0) {
            if (arrElements.length > 1)
                titleAdds += "system " + st;
            else
                titleAdds += "element " + st;
            let comp = app.filter.CompositionItems;
            for (let i = 0; i < comp.length; i++) { // compositions
                let el = comp[i].ElementName;
                if (el == null || el == "")
                    el = "X";
                if (comp[i].ValueAbsoluteMin && (comp[i].ValueAbsoluteMin != "" || comp[i].ValueAbsoluteMax != "")) {
                    titleAdds += (titleAdds == "" ? "" : " and ") + el + " in [" + comp[i].ValueAbsoluteMin + "; " + comp[i].ValueAbsoluteMax + "]";
                } else if (comp[i].ValuePercentMin && (comp[i].ValuePercentMin != "" || comp[i].ValuePercentMax != "")) {
                    titleAdds += (titleAdds == "" ? "" : " and ") + el + " in [" + comp[i].ValuePercentMin + "%; " + comp[i].ValuePercentMax + "%]";
                }
            }
            $(".selectedElementsResult .inactive").hide();
            $("#searchcomposition").show();
            $(".Mendeleev .selectedSystem").html(st + (st != "" ? '&nbsp;&nbsp;&nbsp;[<a href="javascript:void(0)" onclick="Mendeleev_Clear();"><span class="en">clear</span></a>]' : ''));
        } else {
            $(".selectedElementsResult .inactive").show();
            $("#searchcomposition").hide();
            $(".Mendeleev .selectedSystem").html("");
        }
        if (app.filter.PropertyItems.length > 0) {  // TO DO
            let prop = app.filter.PropertyItems;
            for (let i = 0; i < prop.length; i++) { // properties
                let name = prop[i].PropertyName;
                if (name == null || name == "" || prop[i].PropertyType == "")
                    continue;
//console.log(name);
                let propNameObj = app.propertyNames.find(element => element.type == prop[i].PropertyType && element.nameShort == name);
//console.log(propNameObj);
                if (typeof propNameObj !== "undefined") {
                    name = propNameObj.name;
                }
                if (prop[i].PropertyType == "Int" || prop[i].PropertyType == "Float") {
                    titleAdds += (titleAdds == "" ? "" : " and ") + name + " in [" + prop[i].ValueMin + "; " + prop[i].ValueMax + "]";
                } else if (prop[i].PropertyType == "String" || prop[i].PropertyType == "BigString") {
                    titleAdds += (titleAdds == "" ? "" : " and ") + name + " " + (GetStringComareText(prop[i].ValueMax)) + " '" + prop[i].ValueString + "'";
                }
            }
        }
        if (app.filter.TypeId != 0) {
            titleAdds += (titleAdds == "" ? "" : " and ") + "type is " + GetTypeName(app.filter.TypeId);
        }
        if (app.filter.SearchPhrase.length > 0) {
            titleAdds += (titleAdds == "" ? "" : " and ") + "search phrase like " + app.filter.SearchPhrase;
        }
        if (app.filter.CreatedByUser != 0) {
            titleAdds += (titleAdds == "" ? "" : " and ") + "user-creator is " + $("#CreatedByUser option[value='" + app.filter.CreatedByUser + "']").text();
        }
        if (app.filter.CreatedMin.length > 0) {
            titleAdds += (titleAdds == "" ? "" : " and ") + "created >= " + app.filter.CreatedMin;
        }
        if (app.filter.CreatedMax.length > 0) {
            titleAdds += (titleAdds == "" ? "" : " and ") + "created <= " + app.filter.CreatedMax;
        }
        if (app.filter.ObjectId != 0) {
            titleAdds += (titleAdds == "" ? "" : " and ") + "ObjectId is " + app.filter.ObjectId;
        }
        if (app.filter.ExternalId != 0) {
            titleAdds += (titleAdds == "" ? "" : " and ") + "ExternalId is " + app.filter.ExternalId;
        }

        title = "Search results filtered by " + titleAdds;
        // match with function GetFilterByRequest in site.js
        let par = [
            { "name": "system", "value": st },
            { "name": "typeid", "value": app.filter.TypeId },
            { "name": "searchphrase", "value": app.filter.SearchPhrase },
            { "name": "createdbyuser", "value": app.filter.CreatedByUser },
            { "name": "createdmin", "value": app.filter.CreatedMin },
            { "name": "createdmax", "value": app.filter.CreatedMax },
            { "name": "oid", "value": app.filter.ObjectId },
            { "name": "eid", "value": app.filter.ExternalId }
        ];
        for (i = 0; i < app.filter.CompositionItems.length; i++) {
            if (app.filter.CompositionItems[i].ValueAbsoluteMin != "")
                par.push({ "name": app.filter.CompositionItems[i].ElementName + "absmin", "value": app.filter.CompositionItems[i].ValueAbsoluteMin });
            if (app.filter.CompositionItems[i].ValueAbsoluteMax != "")
                par.push({ "name": app.filter.CompositionItems[i].ElementName + "absmax", "value": app.filter.CompositionItems[i].ValueAbsoluteMax });
            if (app.filter.CompositionItems[i].ValuePercentMin != "")
                par.push({ "name": app.filter.CompositionItems[i].ElementName + "pctmin", "value": app.filter.CompositionItems[i].ValuePercentMin });
            if (app.filter.CompositionItems[i].ValuePercentMax != "")
                par.push({ "name": app.filter.CompositionItems[i].ElementName + "pctmax", "value": app.filter.CompositionItems[i].ValuePercentMax });
        }
        for (i = 0; i < app.filter.PropertyItems.length; i++) {
            if (app.filter.PropertyItems[i].PropertyName != "")
                par.push({ "name": "pr" + i + "name", "value": app.filter.PropertyItems[i].PropertyName });
            if (app.filter.PropertyItems[i].PropertyType != "")
                par.push({ "name": "pr" + i + "type", "value": app.filter.PropertyItems[i].PropertyType });
            if (app.filter.PropertyItems[i].ValueMin != "")
                par.push({ "name": "pr" + i + "min", "value": app.filter.PropertyItems[i].ValueMin });
            if (app.filter.PropertyItems[i].ValueMax != "")
                par.push({ "name": "pr" + i + "max", "value": app.filter.PropertyItems[i].ValueMax });
            if (app.filter.PropertyItems[i].ValueString != "")
                par.push({ "name": "pr" + i + "str", "value": app.filter.PropertyItems[i].ValueString });
        }
        if (app.filter.PropertyItems.length > 0)
            par.push({ "name": "prcnt", "value": app.filter.PropertyItems.length.toString() });

        url = FormQueryString(par);

        // Updates Samples list
        UpdateFilteredList();
    } else {    // reset filter
// console.log("Mendeleev_doMain: reset filter");
        title = "Search";
        url = FormQueryString([]);
        RenderPeriodicTableAvailableElements(app.initElementsArr);
        RenderUsersAvailable(app.initPersonsArr);
        $(".Mendeleev .selectedSystem").html("");
        // Empty Samples list
        $('#listContainer').html('<p class="inactive">Please select some elements...</p>');
        $(".selectedElementsResult .inactive").show();
        $("#searchcomposition").hide();

        Mendeleev_Clear(true);
    }
    $("head title").text(title);
    if (titleAdds == "") {
        $("h1").html("Search");
    } else {
        $("h1").html("Search <small>" + titleAdds + "</small>");
    }
    history.pushState(null, title, url);
}

// form QueryString  from array of {name, value} pairs
function FormQueryString(nameValuePairsArray) {
    if (nameValuePairsArray.length == 0)
        return app.initPath + "/";
//console.log("FormQueryString:" + JSON.stringify(nameValuePairsArray));
    var kv = nameValuePairsArray.filter(x => x.value && x.value.length > 0);
    var nkv = kv.map(x => x.name + "=" + encodeURIComponent(x.value));
    return app.initPath + "/?" + nkv.join('&');
}


// Fills the names of properties of corresponding types
// propType == one of { 'Float', 'Int', 'String', 'BigString'}
function FillDataList(propType, options) {
    if (document.getElementById("PropNames" + propType) != null)  // all filled
        return;
    var l = $("#PropNames" + propType + " option").length;
    var typeId = $("#TypeId").val();
    var queryData = { "propertyType": propType, "typeId": typeId };
    $('#datalist .err').html("");
    let async = true;
    if (typeof options !== "undefined" && options["async"] == false) {
        async = false;    // TO DO: REQUIRED on InitOnly => get rid of this
    }
//console.log("FillDataList : " + JSON.stringify(queryData) + "; async = " + async);
    $.ajax({
        async: async,   
        type: "POST",
        url: "/search/getpropertynames",
        data: queryData,
        dataType: "json",
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            $('#datalist .err').html("ajax error (textStatus" + textStatus + "errorThrown: " + errorThrown + ")");
        },
        success: function (data, status) {
            if (document.getElementById("PropNames" + propType) != null)  // all filled
                return;
//console.log("FillDataList: " + JSON.stringify(queryData) + "\r\n: " + JSON.stringify(data));
            var html = "<datalist id=\"PropNames" + propType + "\">\r\n";
            if (data.length > 0) {
                for (i = 0; i < data.length; i++) {
                    app.propertyNames.push({ type: propType, nameShort: RemoveHtmlTags(data[i]), name: data[i] });
                    html += "<option>" + data[i] + "</option>";
                }
//console.log(app.propertyNames);
            }
            html += "</datalist>";
            $('#datalist').append(html);
        }
    });
}

// show initialization via config object { initSelectedElements - selected system, e.g., "As-Ga" or ["As", "Ga"]); it runs only once
function Mendeleev_doInit(initObj) {
    // highlight selected elements by arrSelectedSystem
    HighlightSelectedElements(initObj.CompositionItems);

    // set text in input for SearchPhrase
    SetTypeId(initObj.TypeId);
    SetSelectedSearchPhrase(initObj.SearchPhrase);
    SetCreatedByUser(initObj.CreatedByUser);
    SetSelectedCreatedMin(initObj.CreatedMin);
    SetSelectedCreatedMax(initObj.CreatedMax);
    SetInt("ObjectId", initObj.ObjectId);
    SetInt("ExternalId", initObj.ExternalId);
    if (initObj.PropertyItems.length > 0 || initObj.TypeId != 0 || initObj.SearchPhrase != "" || initObj.CreatedByUser != 0 || initObj.CreatedMin != "" || initObj.CreatedMax != "" || initObj.ObjectId != 0 || initObj.ExternalId != 0) {
// console.log("collapseFilterAdditionalGroup => SHOW ");
// console.log("collapseFilterAdditionalGroup => initObj.searchphrase=" + initObj.searchphrase + ", initObj.createdbyperson=" + initObj.createdbyperson + ", initObj.createdmin=" + initObj.createdmin + ", initObj.createdmax=" + initObj.createdmax);
        // UpdateSearchPropertiesTable(initObj.PropertyItems);
        $("#collapseFilterAdditionalGroup").addClass("show");
        $("#btnCollapseFilterAdditionalGroup").attr("aria-expanded", "true").removeClass("collapsed");
        $("#collapseFilterSpecial").addClass("show");
        if (initObj.ObjectId != 0 || initObj.ExternalId != 0) {   // "Specific search" button
            $("#collapseFilterSpecialForm").addClass("show");
            $("#btnCollapseFilterSpecial").attr("aria-expanded", "true").removeClass("collapsed");
        }
    }

    for (i = 0; i < initObj.PropertyItems.length; i++) {    // initialize popup types
        var pt = initObj.PropertyItems[i].PropertyType;
//console.log("Mendeleev_doInit: FillDataList");
        FillDataList(pt, { async: false });    // fill preset property names
    }

    $('.buttonSearch').click(function () { Mendeleev_doMain(); });
    $('#searchphrase, .fieldSearch').keypress(function (e) {
        if (e.which == 13) {
            Mendeleev_doMain();
            return false;
        }
    });

    $(".Mendeleev .element").click(function () { // при клике на элементе
        $(this).toggleClass("selected"); // поменяли класс selected
        Mendeleev_doMain();
    });

    $(window).resize(function () {
        Mendeleev_myResize();
    });

    Mendeleev_myResize();
// console.log("Mendeleev_doInit arrSystem: " + JSON.stringify(arrSelectedSystem) + ", searchPhrase: " + initObj.searchphrase + ", createdbyperson: " + initObj.createdbyperson + ", createdmin: " + initObj.createdmin + ", createdmax: " + initObj.createdmax);
//console.log("Mendeleev_doInit: Mendeleev_doMain");
    Mendeleev_doMain();
}







// ============================================================================================================================
// ============================================================================================================================
// ============================================================================================================================
// ============================================================================================================================
// ============================================================================================================================


/*
function UpdateSearchPropertiesTable(arr) {
    //this.PropertyName = PropertyName;
    //this.PropertyType = PropertyType;
    //this.ValueMin = ValueMin;
    //this.ValueMax = ValueMax;
    //this.ValueString = ValueString;

    let arrSelectedSystem = arr.map(x => x.ElementName);
    if (document.getElementById("SearchCompoundTableBody") == null)
        return;
    // remove Rows that are not in chemical system
    $("#SearchCompoundTableBody>tr").each(function () {
        var el = $(this).attr("data-element");
        if (el != "" && !arrSelectedSystem.includes(el))
            $(this).remove();
    });
    // add non-existent Rows
    for (i = 0; i < arr.length; i++) {
        if ($("#SearchCompoundTableBody>tr[data-element='" + arr[i].ElementName + "']").length > 0)
            continue;
        var html = $("#SearchCompoundTableBody>tr[data-element='']").prop('outerHTML');
        //console.log("PRE: " + html);
        html = html.replace('<tr data-element="">', '<tr data-element="' + arr[i].ElementName + '">');
        html = html.replace('<input type="hidden" name="element" value="">', arr[i].ElementName + '<input type="hidden" name="element" value="' + arr[i].ElementName + '">');
        html = html.replace('input name="ValueAbsoluteMin"', 'input name="' + arr[i].ElementName + '_ValueAbsoluteMin" value="' + (arr[i].ValueAbsoluteMin != null ? arr[i].ValueAbsoluteMin : "") + '"');
        html = html.replace('input name="ValueAbsoluteMax"', 'input name="' + arr[i].ElementName + '_ValueAbsoluteMax" value="' + (arr[i].ValueAbsoluteMax != null ? arr[i].ValueAbsoluteMax : "") + '"');
        html = html.replace('input name="ValuePercentMin"', 'input name="' + arr[i].ElementName + '_ValuePercentMin" value="' + (arr[i].ValuePercentMin != null ? arr[i].ValuePercentMin : "") + '"');
        html = html.replace('input name="ValuePercentMax"', 'input name="' + arr[i].ElementName + '_ValuePercentMax" value="' + (arr[i].ValuePercentMax != null ? arr[i].ValuePercentMax : "") + '"');
        //console.log("POST: " + html);
        $("#SearchCompoundTableBody").append(html);
    }
}
*/



// press delete buttons in compound table
function DeleteSearchCompoundTableElement(obj) {
    var row = $(obj).closest('tr');
    var el = row.attr("data-element");
    row.remove();
    $(".Mendeleev .element[data-name='" + el + "']").click();   // just call event handler, should be fine
}

function UpdateSearchCompositionTableBySystem() {
    let arr = Mendeleev_doMain_GetCompositionItems();
    // arr = arr.map(x => x.ElementName);
    UpdateSearchCompositionTable(arr);
}

function UpdateSearchCompositionTable(arr) {
    let arrSelectedSystem = arr.map(x => x.ElementName);
    if (document.getElementById("SearchCompoundTableBody") == null)
        return;
    // remove Rows that are not in chemical system
    $("#SearchCompoundTableBody>tr").each(function () {
        var el = $(this).attr("data-element");
        if (el != "" && !arrSelectedSystem.includes(el))
            $(this).remove();
    });
    // add non-existent Rows
    for (i = 0; i < arr.length; i++) {
        if ($("#SearchCompoundTableBody>tr[data-element='" + arr[i].ElementName + "']").length > 0)
            continue;
        var html = $("#SearchCompoundTableBody>tr[data-element='']").prop('outerHTML');
        //console.log("PRE: " + html);
        html = html.replace('<tr data-element="">', '<tr data-element="' + arr[i].ElementName + '">');
        html = html.replace('<input type="hidden" name="element" value="">', arr[i].ElementName + '<input type="hidden" name="element" value="' + arr[i].ElementName + '">');
        html = html.replace('input name="ValueAbsoluteMin"', 'input name="' + arr[i].ElementName + '_ValueAbsoluteMin" value="' + (arr[i].ValueAbsoluteMin != null ? arr[i].ValueAbsoluteMin : "") + '"');
        html = html.replace('input name="ValueAbsoluteMax"', 'input name="' + arr[i].ElementName + '_ValueAbsoluteMax" value="' + (arr[i].ValueAbsoluteMax != null ? arr[i].ValueAbsoluteMax : "") + '"');
        html = html.replace('input name="ValuePercentMin"', 'input name="' + arr[i].ElementName + '_ValuePercentMin" value="' + (arr[i].ValuePercentMin != null ? arr[i].ValuePercentMin : "") + '"');
        html = html.replace('input name="ValuePercentMax"', 'input name="' + arr[i].ElementName + '_ValuePercentMax" value="' + (arr[i].ValuePercentMax != null ? arr[i].ValuePercentMax : "") + '"');
        //console.log("POST: " + html);
        $("#SearchCompoundTableBody").append(html);
    }
}

function MakeSearchSortableTable() {
    var $tableBody = $('#SearchCompoundTable>tbody');
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
