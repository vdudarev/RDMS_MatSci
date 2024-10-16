// Please see documentation at https://docs.microsoft.com/aspnet/core/client-side/bundling-and-minification
// for details on configuring this project to bundle and minify static web assets.

var chemicalElements = ["H", "He", "Li", "Be", "B", "C", "N", "O", "F", "Ne", "Na", "Mg", "Al", "Si", "P", "S", "Cl", "Ar", "K", "Ca", "Sc", "Ti", "V", "Cr", "Mn", "Fe", "Co", "Ni", "Cu", "Zn", "Ga", "Ge", "As", "Se", "Br", "Kr", "Rb", "Sr", "Y", "Zr", "Nb", "Mo", "Tc", "Ru", "Rh", "Pd", "Ag", "Cd", "In", "Sn", "Sb", "Te", "I", "Xe", "Cs", "Ba", "La", "Ce", "Pr", "Nd", "Pm", "Sm", "Eu", "Gd", "Tb", "Dy", "Ho", "Er", "Tm", "Yb", "Lu", "Hf", "Ta", "W", "Re", "Os", "Ir", "Pt", "Au", "Hg", "Tl", "Pb", "Bi", "Po", "At", "Rn", "Fr", "Ra", "Ac", "Th", "Pa", "U", "Np", "Pu", "Am", "Cm", "Bk", "Cf", "Es", "Fm", "Md", "No", "Lr", "Rf", "Db", "Sg", "Bh", "Hs", "Mt", "Ds", "Rg", "Cn", "Nh", "Fl", "Mc", "Lv", "Ts", "Og"];


function AccessFilter(AccessControl, UserId) {
    this.AccessControl = AccessControl; // Public = 0, Protected = 1, ProtectedNDA=2, Private = 3  //     None = -1,      // AdminMode
    this.UserId = UserId
}

function FilterCompositionItem(ElementName, ValueAbsoluteMin, ValueAbsoluteMax, ValuePercentMin, ValuePercentMax) {
    this.ElementName = ElementName;
    this.ValueAbsoluteMin = ValueAbsoluteMin;
    this.ValueAbsoluteMax = ValueAbsoluteMax;
    this.ValuePercentMin = ValuePercentMin;
    this.ValuePercentMax = ValuePercentMax;
}

function FilterPropertyItem(PropertyName, PropertyType, ValueMin, ValueMax, ValueString) {
    this.PropertyName = PropertyName;
    this.PropertyType = PropertyType;
    this.ValueMin = ValueMin;
    this.ValueMax = ValueMax;
    this.ValueString = ValueString;
}

function Filter(AccessFilter, CompositionItems, PropertyItems, TypeId, SearchPhrase, CreatedByUser, CreatedMin, CreatedMax, ObjectId, ExternalId) {
    this.AccessFilter = AccessFilter;
    this.CompositionItems = CompositionItems; // FilterCompositionItem { ElementName:"", ValueAbsoluteMin:null, ValueAbsoluteMax:null, ValuePercentMin:null, ValuePercentMax:null }
    this.PropertyItems = PropertyItems;  // FilterPropertyItem { PropertyName:"", PropertyType:"", ValueMin:null, ValueMax:null, ValueString:"" }
    this.TypeId = TypeId;
    this.SearchPhrase = SearchPhrase;
    this.CreatedByUser = CreatedByUser;
    this.CreatedMin = CreatedMin;
    this.CreatedMax = CreatedMax;
    this.ObjectId = ObjectId;
    this.ExternalId = ExternalId;
}

// parses request parameters to create filter object
// match with function Mendeleev_doMain in filterScripts.js
function GetFilterByRequest() {
    const params = new Proxy(new URLSearchParams(window.location.search), {
        get: function (searchParams, prop) { return searchParams.get(prop); },
    });
// console.log("QueryString system: " + params.system + ",projectname: " + params.projectname + ", createdbyuser: " + params.createdbyuser + ", createdmin: " + params.createdmin + ", createdmax: " + params.createdmax);
    //return new Filter();
    let initObj = {
        "CompositionItems": [],
        "PropertyItems": [],
        "TypeId": params.typeid == null ? 0 : params.typeid,
        "SearchPhrase": params.searchphrase == null ? "" : params.searchphrase,
        "CreatedByUser": params.createdbyuser == null ? 0 : params.createdbyuser,
        "CreatedMin": params.createdmin == null ? "" : params.createdmin,
        "CreatedMax": params.createdmax == null ? "" : params.createdmax,
        "ObjectId": params.oid == null ? 0 : params.oid,
        "ExternalId": params.eid == null ? 0 : params.eid
    }
    if (params.system != null) {
        let elArr = params.system.split("-") ?? [];
        for (i = 0; i < elArr.length; i++) {
            let el = elArr[i];
            let comp = new FilterCompositionItem(el, params[el + "absmin"], params[el + "absmax"], params[el + "pctmin"], params[el + "pctmax"]);
            initObj.CompositionItems.push(comp);
        }
    }
    if (params.prcnt != null && parseInt(params.prcnt) > 0) {  // e.g. prcnt=2
        let propLength = parseInt(params.prcnt);
        for (i = 0; i < propLength; i++) {
            var t = params["pr" + i + "type"];
            // FillDataList(t);    // fill preset property names is done in Mendeleev_doInit
            let prObj = new FilterPropertyItem(params["pr" + i + "name"], t, params["pr" + i + "min"], params["pr" + i + "max"], params["pr" + i + "str"]);
            initObj.PropertyItems.push(prObj);
        }
    }
//console.log("GetFilterByRequest: " + JSON.stringify(initObj));
    return initObj;
}

function GetStringComareText(code) {
    if (code == "0")
        return "equal";
    if (code == "1")
        return "starts with";
    if (code == "2")
        return "ends with";
    if (code == "3")
        return "contains";
    return "UNKNOWN"
}

var app = {
    path: "",
    queryString: "",
    objectId: 0,
    object: null,   // current object
    types: [],  // list of known types
    type: null, // current type
    func_onSystemRender: [],
    curSystem: null,
    initPath: "/search",
    initElementsArr: [],
    initPersonsArr: [],
    initTypesArr: [],
    filter: {
        // unimportant here, since it is taken from server context
        AccessFilter: { AccessControl: 0, UserId: 0 },  // AccessControl: Public = 0, Protected = 1, ProtectedNDA = 2, Private = 3  //     None = -1,      // AdminMode
        CompositionItems: [], // FilterCompositionItem { ElementName:"", ValueAbsoluteMin:null, ValueAbsoluteMax:null, ValuePercentMin:null, ValuePercentMax:null }
        PropertyItems: [],  // FilterPropertyItem { PropertyName:"", PropertyType:"", ValueMin:null, ValueMax:null, ValueString:"" }
        TypeId: 0,
        SearchPhrase: "",
        CreatedByUser: 0,
        CreatedMin: "",
        CreatedMax: "",
        ObjectId: 0,
        ExternalId: 0
    },
    propertyNames: [],      // { type: propType, nameShort: RemoveHtmlTags(data[i]), name: data[i] }     - names for 4 types of properties
    chart: { labels: [], data: [], title: "" },
    allObjects: { ids: [], curIndex: 0, ok: 0, fail: 0, reloadok: 0, reloadfail: 0, active: false },
    chunkedUpload: false,    // by default==false - regular upload; otherwise==true - chunked upload
    onLoadFunctions: []		// functions that we need to call after onLoad event
};

// function for collapsing and decollapsing tree structure in table
function OpenClose(prefix, spanName, classCollapsed) {
    $(prefix + " " + spanName).click(function () {   // name click! => hide / show
        var data = $(this).closest("tr.datarow").data();
        var id = data.id;
        var path = data.path + "}";
        // console.log(JSON.stringify(data));
        if ($(prefix + "tr.datarow[data-id=\"" + id + "\"]").hasClass(classCollapsed)) {  // has class (hidden) => show rows
            OpenClose_Show(prefix, classCollapsed, id, path)
        } else {    // has no class (shown) => hide rows
            OpenClose_Hide(prefix, classCollapsed, id, path)
        }
    });
}

// open (show) node
function OpenClose_Show(prefix, classCollapsed, id, path) {
    $(prefix + "tr.datarow[data-path^='" + path + "'][data-id!=\"" + id + "\"]").attr("style", "").removeClass(classCollapsed);
    $(prefix + "tr.datarow[data-path^='" + path + "'][data-id!=\"" + id + "\"] span.name.bi-caret-right-fill").addClass("bi-caret-down-fill").removeClass("bi-caret-right-fill");
    $(prefix + "tr.datarow[data-id=\"" + id + "\"] span.name").addClass("bi-caret-down-fill").removeClass("bi-caret-right-fill");
    $(prefix + "tr.datarow[data-id=\"" + id + "\"]").removeClass(classCollapsed);
}

// close (hide) node
function OpenClose_Hide(prefix, classCollapsed, id, path) {
    $(prefix + "tr.datarow[data-path^='" + path + "'][data-id!=\"" + id + "\"]").attr("style", "display:none").addClass(classCollapsed);
    $(prefix + "tr.datarow[data-path^='" + path + "'][data-id!=\"" + id + "\"] span.name.bi-caret-down-fill").removeClass("bi-caret-down-fill").addClass("bi-caret-right-fill");
    $(prefix + "tr.datarow[data-id=\"" + id + "\"] span.name").removeClass("bi-caret-down-fill").addClass("bi-caret-right-fill");
    $(prefix + "tr.datarow[data-id=\"" + id + "\"]").addClass(classCollapsed);
}

// hide empty (unfilled sections)
function CollapseEmpty(prefix, classCollapsed) {
    let st = "";
    $(prefix + "tr.datarow.table-primary[data-countfilledchildren='0']").each(function () {
        const id = $(this).attr("data-id");
        const path = $(this).attr("data-path");
        st += `separator: ${path} [id=${id}]\r\n`;

        if (!($(prefix + "tr.datarow[data-id=\"" + id + "\"]").hasClass(classCollapsed))) {  // missing class (shown) => hide rows
            OpenClose_Hide(prefix, classCollapsed, id, path);
        }
    });
    console.log(st);
}

function ShiftNonSamples(selector) {
    $(selector + " .list-group-item[data-typeid!='6']").attr("style", "margin-left:3rem");
    $("#ShiftNonSamplesBtn").hide();
}
function HideNonSamples(selector) {
    $(selector + " .list-group-item[data-typeid!='6']").addClass("d-none");
    $("#HideNonSamplesBtn").hide();
}

// display error message
function SpawnError(message, selector) {
    selector = selector || "#alerts";
    let htmlMarkup = (message || "") != "" ? '<div class="alert alert-danger alert-dismissible" role="alert">' + message + '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button></div>' : "";
    $(selector).html(htmlMarkup);
}
// set input focus to the element
function SetFocus(elementId) {
    document.getElementById(elementId).focus();
}

// press button "Add Handover"
function AddHandover() {
    ShowModal("myAddHandover");
    // populate #DestinationUserId
    PopulateUsers("#DestinationUserId");
}
async function PopulateUsers(selector) {
    if ($(selector + " option[value!='']").length > 0)
        return;
    let data = await $.ajax({
        async: true,
        type: "GET",
        url: "/ajax/getusers",
        data: {},
        dataType: "json"
    })
    $.each(data, function (i, item) {
        $(selector).append($('<option>', {
            value: item.id,
            text: item.project ? `${item.project}) ${item.name} [${item.email}]` : `${item.name} [${item.email}]`
        }));
    });
}

let sortCodeAdded = 0;  // no sort code initially
// adds to list items on the page SortCode from a backup data-sortcode attribute
function AddSortCodeToItems() {
    if (sortCodeAdded == 0) {
        sortCodeAdded++;
        $("div.list-group-item[data-sortcode]").each(function () {
            const sortCode = $(this).attr("data-sortcode");
            $(this).append(`<small class="date">Sort Code: ${sortCode}</small>`);
        })
    }
}

async function AdjustLink(LinkedRubricId, ObjectId) {
    $("#myModalAdjustLink input[name='mode']").val(0);
    $("#myModalAdjustLink input[name='objectid']").val(ObjectId);
    // $("#myModalAdjustLink input[name='rubricid']").val(LinkedRubricId);

    AddSortCodeToItems();

    data = await $.ajax({
        async: true,
        type: "GET",
        url: "/ajax/getsortcode_objectlinkrubric",
        data: { objectid: ObjectId, rubricid: LinkedRubricId },
        dataType: "json"
    });

    console.log(data);
    if (data.error != "" || parseInt(data.objectLinkRubric.objectLinkRubricId) < 1) { // error
        $("#myModalAdjustLink #updErr").html('<span class="text-danger">' + (data.error != "" ? data.error : "objectLinkRubricId < 1") + '</span>').show();
        $("#myModalAdjustLink #update").hide();
    }
    else {
        $("#myModalAdjustLink #sortcode").val(data.objectLinkRubric.sortCode);
        $("#myModalAdjustLink input[name='objectlinkrubricid']").val(data.objectLinkRubric.objectLinkRubricId);
        $("#myModalAdjustLink #updErr").hide();
        $("#myModalAdjustLink #update").show();
    }
    // alert(`to be implemented [LinkedRubricId=${LinkedRubricId}, ObjectId=${ObjectId}]`);

    // show dialogue
    ShowModal("myModalAdjustLink");
}


// adjust width of .ctrlButtons width
function AdjustCtrlButtons() {
    $(".ctrlButtons").each(function () {
        let len = $(this).find("a").length;
        //console.log("AdjustCtrlButtons: " + len);
        $(this).attr("style", "min-width:" + (60 * len) + "px");
    });
}
function DisableButton(idElement, mode) {
    mode = mode || true;
    document.getElementById(idElement).disabled = mode;
    return true;
}

async function DnDUploadSubmit() {
    // DisableButton('DnDUploadChunk');    // disable new multi-button (if disabled, form can not be submitted)
    //DisableButton('DnDUpload'); // old form upload mode
    $("#DnDUploadWaiter").removeClass("d-none");    // show waiter
    let data = {};
    $("#addfiles input[type='hidden']").each(function () {
        const name = $(this).attr("name");
        const value = $(this).attr("value");
        data[name] = value;
    });
    console.log(data);
    let ajaxData = await $.ajax({
        async: true,
        type: "POST",
        url: "/uploadfiles/stagefilesinit",
        data: data,
        dataType: "json"
    });
    const fileInput = document.getElementById('fileupload');
    const files = fileInput.files;
    if (app.chunkedUpload && files.length) {    // new chunked upload (except Safari)
        await uploadFilesChunked(); // new chunked upload
        document.getElementById("fileupload").value = "";
//alert("chunkedUpload ok!");
        document.location = "/uploadfiles";
        return false;
    }
//alert(`NOT chunkedUpload ok: app.chunkedUpload=${app.chunkedUpload}; files.length=${files.length}`);
    // $("#DnDUploadChunk").attr("type", "submit");   // standard form sending (does not work)
    document.getElementById('addfiles').submit();
    //DisableButton('DnDUploadChunk', false); // make button active. otherwise can't submit the form
    return true;
}


async function uploadFilesChunked() {
    const fileInput = document.getElementById('fileupload');
    const files = fileInput.files;
    if (!files.length || files.length < 1) {
        console.log(`Please select file(s)! [files.length=${files.length}]`);
        /*
        DisableButton('DnDUploadChunk', false); // make button active
        $("#DnDUploadWaiter").addClass("d-none");   // hide waiter
        return;
        */
    }
    /*
            $("#ValidateAllOneByOneProgress").removeClass("d-none");
            let progress=0;
            // run the sequence - loop
            for (let i = 0; i < app.allObjects.ids.length; i++) {
                progress = Math.round(i * 100 / app.allObjects.ids.length);
                $("#ValidateAllOneByOneProgress div").html(i + " of " + app.allObjects.ids.length).attr("style", "width:" + progress + "%").attr("aria-valuenow", progress);
                // console.log("ValidateAllOneByOne " + i + " => " + app.allObjects.ids[i]);
                await ValidateFileType(app.allObjects.ids[i]);
            }
            let timeFinish = (new Date()).getTime();
            const timeSec = ((timeFinish - timeStart) / 1000);
            $("#msgValidation").html("Validation completed: ok: " + app.allObjects.ok + ", fail: " + app.allObjects.fail + " [time taken: " + timeSec + " s]");
            $("#ValidateAllOneByOneWaiter").addClass("d-none");
            $("#ValidateAllOneByOneProgress").addClass("d-none");
            app.allObjects.active = false;    
    */

    const chunkSize = 100 * 1024 * 1024; // 100MB chunks

    for (let idx = 0; idx < files.length; idx++) {
        const file = files[idx];
        $("#DnDUploadProgress").removeClass("d-none");

        const totalChunks = Math.ceil(file.size / chunkSize);

        for (let chunkNumber = 0; chunkNumber < totalChunks; chunkNumber++) {
            const start = chunkNumber * chunkSize;
            const end = Math.min(start + chunkSize, file.size);
            const chunk = file.slice(start, end);

            const formData = new FormData();
            formData.append('chunk', chunk);
            formData.append('fileName', file.name);
            formData.append('chunkNumber', chunkNumber + 1);
            formData.append('totalChunks', totalChunks);

            try {
                const response = await fetch('/uploadfiles/uploadchunk', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) {
                    throw new Error(`Chunk upload failed: chunk ${chunkNumber} of ${totalChunks} in ${file.name}`);
                }

                // Update the progress bar
                const progress = Math.round(((chunkNumber + 1) / totalChunks) * 100);
                $("#DnDUploadProgress div").html(file.name + " - " + progress + "% [" + (chunkNumber + 1) + " of " + totalChunks + "]").attr("style", "width:" + progress + "%").attr("aria-valuenow", progress);
            } catch (error) {
                console.error(error);
                console.error(`Error uploading chunk ${chunkNumber} of ${totalChunks} in ${file.name}: `, error);
                return;
            }
        }
        $("#DnDUploadProgress").addClass("d-none");
    }
    //alert('All files uploaded successfully.');
}



async function PopulateUsers(selector) {
    if ($(selector + " option[value!='']").length > 0)
        return;
    let data = await $.ajax({
        async: true,
        type: "GET",
        url: "/ajax/getusers",
        data: {},
        dataType: "json"
    })
    $.each(data, function (i, item) {
        $(selector).append($('<option>', {
            value: item.id,
            text: item.project ? `${item.project}) ${item.name} [${item.email}]` : `${item.name} [${item.email}]`
        }));
    });
}




/*
function headerSidChanged() { // onkeyup
    const val = $("#sid").val();
    if (isNaN(parseInt(val)) && val != "")
        $("#sid_err").removeClass("d-none");
    else
        $("#sid_err").addClass("d-none");
    return val;
}
*/
/// submit of Go To ObjectId form in the header
function headerSidSubmit() {
    const val = $("#sidform input[name='sid']").val();    // headerSidChanged();
    if (!isNaN(parseInt(val))) {
        let smode = $("#sidform input[name='smode']").val() // "id" | "externalid"
        if (smode == "") {
            smode = "id";
        }
        $("#sidform").attr("action", "/object/" + smode + "/" + parseInt(val));
        return true;
    }
    return false;
}


function AddMonth(st) { 
        const i = st.indexOf('-');
        let year = parseInt(st.substring(0, 4));
        let month = parseInt(st.substring(5, 7));
        if (month < 12) {
            month++;
        }
        else { 
            month=1;
            year++;
        }
        return year + '-' + (month).toLocaleString('en-US', { minimumIntegerDigits: 2, useGrouping: false });
}

function searchByUserId(userid) {
    // console.log("SearchByUserId: " + userid);
    if (userid == '')
        document.location = '?';
    else
        document.location = '?userid=' + userid;
}

function Delay(milliseconds) {
    return new Promise(resolve => setTimeout(resolve, milliseconds));
}

function isActiveFilter(filterObj) {
    // filterObj.AccessFilter.AccessControl >= 0 ||
    res = filterObj.CompositionItems.length > 0 || filterObj.PropertyItems.length > 0
        || filterObj.TypeId != 0 || filterObj.SearchPhrase.length > 0 || filterObj.CreatedByUser != 0
        || filterObj.CreatedMin.length > 0 || filterObj.CreatedMax.length > 0
        || filterObj.ObjectId != 0 || filterObj.ExternalId != 0;
//console.log("isActiveFilter("+res+"): " + JSON.stringify(filterObj));
    return res;
}

function initDataTable(selector, options) {
    selector = selector || '#searchList';
    if (! $(selector).length) {
        console.log(`initDataTable: ${selector} not found, quit...`);
        return;
    }
    options = options || {
        paging: false,
        searching: false,
        fixedHeader: {
            header: true,
            footer: false
        }
    };
    $(selector).DataTable(options);
}

function GetType(typeId) {
    for (var i = 0; i < app.types.length; i++)
        if (app.types[i].TypeId == typeId)
            return app.types[i];
    return null;
}

function GetTypeName(typeId) {
    let t = GetType(typeId);
    return t == null ? "unknown type" : t.TypeName;
}

function RemoveHtmlTags(st) {
    st = st.replace("<sub>", "").replace("</sub>", "");
    st = st.replace("<sup>", "").replace("</sup>", "");
    return st;
}

function ShowModal(id) {
    let myModalEl = document.querySelector('#' + id);
    let myModal = bootstrap.Modal.getOrCreateInstance(myModalEl); // Returns a Bootstrap modal instance
    myModal.show();
}

function addPrefixIfNotEmpty(prefix, str) {
    if (str != "" && str != null) {
        str = prefix + str;
    }
    return str;
}

// =======================================================================================================
// =======================================================================================================
// =======================================================================================================
// Gets data values from file
// prereqisites: use on page: <partial name="pDataModel" model="false" />
function ShowDatabaseDataForObject(objectId) {
    // console.log("ShowDatabaseDataForObject" + objectId);
    $.ajax({
        type: "POST",
        url: "/adminobject/getdatavalues",
        data: { objectId: objectId },
        dataType: "json",
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            let msg = XMLHttpRequest.responseText;
            if (msg.indexOf('\n') > 0) {
                msg = msg.substr(0, msg.indexOf('\n'))
            }
            $("#objData" + objectId).removeClass("d-none").html(msg);
            $("#dataModalCenteredScrollable pre").text(msg);
            ShowModal("dataModalCenteredScrollable");
        },
        success: function (data, status) {
            // console.log(data);
            $("#dataModalCenteredScrollable pre").text(JSON.stringify(data, null, 2));
            ShowModal("dataModalCenteredScrollable");
        }
    });
}



// validation of a single file for correspondence with typeId
// https://petetasker.com/using-async-await-jquerys-ajax
async function ValidateFileType(objectId) {
    let data = null;
    try {
        $("#objValidator" + objectId).removeClass("d-none").attr("title", "");
        $("#objReload" + objectId).addClass("d-none").attr("title", "");
        $("#objValidator" + objectId + " .bi").removeClass("bi-bag-check").removeClass("bi-bag-x").addClass("bi-hourglass-split").html("");
        $("#objData" + objectId).addClass("d-none");  // hide Data icon on object
        data = await $.ajax({
            async: true,
            type: "GET",
            url: "/object/validate/" + objectId,
            data: {},
            dataType: "json"
        });
        // get the result
        // console.log(data);
        $("#objValidator" + objectId + " .bi").removeClass("bi-bag-check").removeClass("bi-bag-x").removeClass("bi-hourglass-split").html("");
        if (data.code == 0) {
            app.allObjects.ok++;
            // console.log("OK: objectId" + objectId + "; app.allObjects.ok = " + app.allObjects.ok);
            $("#objValidator" + objectId).attr("title", "valid");
            $("#objValidator" + objectId + " .bi").addClass("bi-bag-check").html(addPrefixIfNotEmpty("Warning: ", data.warning));
            $("#objData" + objectId).removeClass("d-none");  // show Data icon on object
        } else {
            app.allObjects.fail++;
            $("#objValidator" + objectId).attr("title", "invalid");
            $("#objValidator" + objectId + " .bi").addClass("bi-bag-x").html(addPrefixIfNotEmpty("Fail: ", data.message));
            //$("#objValidator" + objectId + " a").addClass("d-none");
        }
    } catch (error) {
        console.error(error);
        /*let msg = XMLHttpRequest.responseText;
        if (msg.indexOf('\n') > 0) {
            msg = msg.substr(0, msg.indexOf('\n'))
        }*/
        $("#objValidator" + objectId + " .bi").removeClass("bi-bag-check").removeClass("bi-bag-x").removeClass("bi-hourglass-split").html("");
        $("#objValidator" + objectId + " .bi").addClass("bi-bag-x").html(error);
        app.allObjects.fail++;
    }
    return data;
}



// reload of file data (if it's valid)
async function ReloadFileType(objectId) {
    let data = null;
    try {
        $("#objValidator" + objectId + ", #objReload" + objectId).removeClass("d-none").attr("title", "");
        $("#objValidator" + objectId + " .bi").removeClass("bi-bag-check").removeClass("bi-bag-x").addClass("bi-hourglass-split").html("");
        $("#objData" + objectId).addClass("d-none");  // hide Data icon on object
        $("#objReload" + objectId + " .bi").removeClass("bi-database-check").removeClass("bi-database-exclamation").addClass("bi-hourglass-split");
        data = await $.ajax({
            async: true,
            type: "POST",
            url: "/object/reload/" + objectId,
            data: {},
            dataType: "json",
        });
        // get the result
        // console.log(data);
        // console.log(data);
        $("#objValidator" + data.objectId + " .bi").removeClass("bi-bag-check").removeClass("bi-bag-x").removeClass("bi-hourglass-split").html("");
        $("#objReload" + data.objectId + " .bi").removeClass("bi-database-check").removeClass("bi-database-exclamation").removeClass("bi-hourglass-split");
        if (data.result.code == 0) {
            $("#objValidator" + data.objectId).attr("title", "valid");
            $("#objValidator" + data.objectId + " .bi").addClass("bi-bag-check").html(addPrefixIfNotEmpty("Warning: ", data.result.warning));
            $("#objData" + data.objectId).removeClass("d-none");  // show Data icon on object
            app.allObjects.ok++;
        } else {
            $("#objValidator" + data.objectId).attr("title", "invalid");
            $("#objValidator" + data.objectId + " .bi").addClass("bi-bag-x").html(addPrefixIfNotEmpty("Fail: ", data.result.message));
            app.allObjects.fail++;
        }
        if (data.reloadResult.code == 0) {
            $("#objReload" + data.objectId).attr("title", "reloaded successfully");
            $("#objReload" + data.objectId + " .bi").addClass("bi-database-check").html(addPrefixIfNotEmpty("Warning: ", data.reloadResult.warning));
            app.allObjects.reloadok++;
        } else {
            $("#objReload" + data.objectId).attr("title", "reloaded with error");
            $("#objReload" + data.objectId + " .bi").addClass("bi-database-exclamation").html(addPrefixIfNotEmpty("Fail: ", data.reloadResult.message));
            app.allObjects.reloadfail++;
        }
    } catch (error) {
        console.error(error);
        /*let msg = XMLHttpRequest.responseText;
        if (msg.indexOf('\n') > 0) {
            msg = msg.substr(0, msg.indexOf('\n'))
        }*/
        $("#objValidator" + objectId + " .bi").removeClass("bi-bag-check").removeClass("bi-bag-x").removeClass("bi-hourglass-split").html("");
        $("#objValidator" + objectId + " .bi").addClass("bi-bag-x").html(msg);
        app.allObjects.reloadfail++;
    }
    return data;
}


// Delete all properties for an object (list and table)
async function DeleteProperties(objectId) {
    let data = null;
    try {
        data = await $.ajax({
            async: true,
            type: "POST",
            url: "/adminobject/deleteproperties",
            data: { "objectId": objectId },
            dataType: "json",
        });
        // get the result
        // console.log(data);
    } catch (error) {
        console.error(error);
    }
    return data;
}


// Delete all associated objects for an object
async function DeleteAssocObjects(objectId) {
    let data = null;
    try {
        data = await $.ajax({
            async: true,
            type: "POST",
            url: "/adminobject/deleteassocobjects",
            data: { "objectId": objectId },
            dataType: "json",
        });
        // get the result
        // console.log(data);
    } catch (error) {
        console.error(error);
    }
    return data;
}

// get parameter from request
function getRequest(name){
   if(name=(new RegExp('[?&]'+encodeURIComponent(name)+'=([^&]*)')).exec(location.search))
      return decodeURIComponent(name[1]);
}


function CreateCookie(name, value, ex_date) {
    var today = new Date();
    today.setDate(today.getDate() + ex_date);
    document.cookie = name + "=" + value + "; expires=" + today.toGMTString() + "; path=/;";
}

function CreateTmpCookie(name, value) {
    document.cookie = name + "=" + value + "; path=/;";
}

function RemoveCookie(name) {
    CreateCookie(name, "", -1);
}

function ReadCookie(name) {
    var tmpName = name + "=";
    if ((startName = atStr(tmpName, document.cookie)) != -1) {
        var startVal = startName + tmpName.length;
        if ((endVal = document.cookie.indexOf(";", startVal)) == -1)
            endVal = document.cookie.length;
        return unescape(document.cookie.substring(startVal, endVal));
    }
    return null;
}

function atStr(sub, str) {
    for (var i = 0; i <= str.length - sub.length; i++)
        if (str.substring(i, i + sub.length).toUpperCase() == sub.toUpperCase()) return i;
    return -1;
}



// make expand/collapse scripts for the properties table
// settings object : { objectFormPrefix: "i7" , CollapseEmpty : true }
function MakePropertiesTableCollapsible(settings) {
    // console.log("MakePropertiesTableCollapsible");
    // console.log(settings);
    settings = settings || { CollapseEmpty: true };
    // console.log(settings);
    const objectFormPrefix = settings.objectFormPrefix || "";
    OpenClose(`#tableAllUnion${objectFormPrefix} `, "span.sepName", "bg-primary");
    if (settings.CollapseEmpty) {
        // hide empty (unfilled sections)
        CollapseEmpty(`#tableAllUnion${objectFormPrefix} `, "bg-primary");
    }
}


// Get all Non-empty Property Names From Search Form
function EnrichWithProperties_GetPropertyNamesFromSearchForm() {
    let propArr = [];
    $("#FilterProperties>.rowitem").each(function () {
        const type = $(this).find("select[name='PropertyType']").val();
        const name = $(this).find("input[name='PropertyName']").val();
        if (type == "" || name == "")
            return;
        propArr.push({ "type": type, "name": name });
    });
    return propArr;
}

function EnrichWithProperties_GetObjectsIdsFound() {
    let objectIds = [];
    $("#searchList>tbody>tr[data-id]").each(function () {
        const id = parseInt($(this).attr("data-id"));
        objectIds.push(id);
    });
    return objectIds;
}

// Enriches table with prpperties on search
async function EnrichWithProperties() {
    const len = $("#FilterProperties>.rowitem").length;
    console.log("EnrichWithProperties: " + len);
    const propArr = EnrichWithProperties_GetPropertyNamesFromSearchForm(); // all properties to add to search
    const objectIds = EnrichWithProperties_GetObjectsIdsFound();
    //console.log(propArr);
    //console.log(objectIds);
    let respData = await $.ajax({
        async: true,
        type: "POST",
        url: "/search/enrichproperties",
        data: { "properties": propArr, "objectIds": objectIds },
        dataType: "json"
    })
    console.log(respData);
    $('#searchList').DataTable().destroy();
    let i, j, val, objId, row;
    row = $("#searchList>thead>tr");
    for (i = 0; i < propArr.length; i++) {
        row.append(`<th>${propArr[i].name}</th>`)
    }
    for (i = 0; i < respData.values.length; i++) {
        objId = respData.values[i].objectId;
        row = $(`#searchList tr[data-id="${objId}"]`);
        console.log("objId = " + objId);
        console.log(respData.values[i]);
        for (j = 0; j < respData.values[i].values.length; j++) {
            // Type = prop.Type, Name = prop.Name, MinValue = res[0].min, MaxValue = res[0].max
            if (respData.values[i].values[j].minValue == respData.values[i].values[j].maxValue) {
                val = respData.values[i].values[j].minValue;
            } else {
                val = respData.values[i].values[j].minValue + " - " + respData.values[i].values[j].maxValue;
            }
            row.append(`<td>${val}</td>`);
        }
    }
    initDataTable('#searchList');
}

// =======================================================================================================
// =======================================================================================================
// =======================================================================================================


class CsvChart {
	sourceData = null;	// data from CSV file, read by d3.dsv()
	innerChart = null;	// a reference to chart.js object
	nameX = "";
	index_X = 0;
	nameY = [];	// array of selected Y axis
	columns;
	delimiter;
	csvUrl;
	selectorErr = "#myChartErr";
	selectorAxisX = "#AxisX";
	selectorAxisY = "#AxisY";

	Xchanged() {
		//console.log("Xchanged - " + this);
		var obj = this;	// this == window.myChart (ATTENTION, see call in the context: function () { context.Xchanged.call(context); })
		if (obj.innerChart != null) {
			// console.log("Xchanged - myChart" + this.myChart);
			obj.innerChart.destroy();
			obj.innerChart == null;
		}
		obj.nameX = $(obj.selectorAxisX).val();
		// radraw available Y axis values:
		var i, st = "", columns = obj.columns;
		// console.log("Xchanged - this.columns" + columns + ", this.nameX = " + obj.nameX);
		for (i = 0; i < columns.length; i++) {
			if (obj.nameX != columns[i]) {
				st += "<option value=\"" + columns[i] + "\">" + columns[i] + "</option>";
			}
		}
		$(obj.selectorAxisY).html(st);
		return true;
	}

	// main Function to DRAW a chart from sourceData
	RebuildChart() {
		//console.log("RebuildChart - " + this);
		var obj = this;	// this == window.myChart (ATTENTION, see call in the context: function () { context.Xchanged.call(context); })
		if (obj.innerChart != null) {
			obj.innerChart.destroy();
			obj.innerChart == null;
		}
		let data = obj.sourceData;
		obj.nameX = $(obj.selectorAxisX).val();		// name for X axis
		obj.index_X = columns.findIndex((x) => x == obj.nameX);	// index for X axis

		obj.Sort(obj.sourceData, obj.nameX);	/// SORT

		obj.nameY = $(obj.selectorAxisY).val();	// array
		if (obj.nameY.length == 0) {
			$(obj.selectorErr).html("Please, select at least one column for Y axis...");
			return;
		}
		$(obj.selectorErr).html("");

		obj.CreateButtons(data);

		// var chartLabels = d3.range(1, data.length);
		let chartLabels = [];
		let i = 0;
		for (i = 0; i < data.length; i++) {
			chartLabels.push(data[i][data.columns[obj.index_X]]);
		}
		//console.log("chartLabels");
		//console.log(chartLabels);

		// data.columns == ['Al', 'Co', 'Ni']
		// console.log("data.columns");
		// console.log(data.columns);

		let config = {
			type: 'line',
			data: {
				labels: chartLabels,
				datasets: []
			},
			options: {
				responsive: true
			}
		};

		obj.innerChart = new window.Chart(
			document.getElementById('myChartCanvas'),
			config
		);

		obj.Draw(data);
	}

	// sort data in table
	Sort(data, field) {
		data.sort(function (x, y) {
			return d3.ascending(parseFloat(x[field]), parseFloat(y[field]));
		})
	}


	// create sort buttons
	CreateButtons(data) {
		let k, st = "";
		for (k = 0; k < data.columns.length; k++) {
			if (k == this.index_X || this.nameY.indexOf(data.columns[k]) < 0)
				continue;
			st += '<button type="button" class="btn btn-primary mr-2" style="margin-right:10px" data-id="' + data.columns[k] + '">Sort by ' + data.columns[k] + '</button>';
		}
		document.getElementById("buttons").innerHTML = st;

		$("#buttons [data-id]").click(function () {
			var id = $(this).attr("data-id");
			console.log("Sort by " + id + " clicked");
			var obj = window.myChart;
			obj.Sort(obj.sourceData, id);
			obj.Draw(obj.sourceData);
		});
	}

	// builds datasets to draw (called from: Sort(), RebuildChart())
	Draw(data) {
		this.innerChart.config.data.datasets = [];
		let k = 0;
		for (k = 0; k < data.columns.length; k++) {
			if (k == this.index_X || this.nameY.indexOf(data.columns[k]) < 0)
				continue;
			var i, d = [];
			for (i = 0; i < data.length; i++) {
				d.push({ x: data[i][data.columns[this.index_X]], y: data[i][data.columns[k]] });
			}

			this.innerChart.config.data.datasets.push({
				label: data.columns[k],
				//backgroundColor: 'rgb(255, 99, 132)',
				//borderColor: 'rgb(255, 99, 132)',
				data: d,
				tension: 0.1
			})
		}

		this.innerChart.update();
	}

//    constructor(csvUrl, delimiter, columns, selectorErr, selectorAxisX, selectorAxisY) {
	constructor(data, columns, selectorErr, selectorAxisX, selectorAxisY) {
		//this.csvUrl = csvUrl;
		//this.delimiter = delimiter;
		this.columns = columns;
		this.selectorErr = selectorErr;
		this.selectorAxisX = selectorAxisX;
		this.selectorAxisY = selectorAxisY;
		this.sourceData = null;
		let context = this;

		//$("#AxisX").on("click", this.Xchanged);
		//$("button.btn.buttonSearch").on("click", this.RebuildChart);
		$("#AxisX").on("change", function () { return context.Xchanged.call(context); });
		$("button.btn.buttonSearch").on("click", function () { context.RebuildChart.call(context); });

		//console.log("constructor: csvUrl = " + csvUrl);

		//d3.dsv(delimiter, csvUrl).then(function (data) {
			//console.log("data");
			//console.log(data);
			//for (i = 0; i < data.length; i++){
			//	data[i].i = i;
			//}

			//window.myChart.sourceData = data;
			//window.myChart.RebuildChart();

			context.sourceData = data;
			context.RebuildChart.call(context);
		//});


		//d3.dsv(delimiter, csvUrl, (data) => {
		//	console.log("constructor: QAZsourceData = " + this.QAZsourceData);
		//	this.sourceData = data;
		//	this.RebuildChart();
		//});
	}
}



// ===================== Bin's wafer plot (EDX) ======================== - BEGIN
function colorLegend(selector_id, x1 = 0, y1 = 0, width = 10, height = 130, min = 0, max = 0, isPercent = true) {
    var group = d3.select(selector_id)
        .append('g').attr('class', 'g_colorlegend').attr('transform', `translate(${x1}, ${y1})`);

    // add legend title
    group.append('text')
        .text(isPercent ? 'at.%' : 'value')
        .attr('x', '10')
        .attr('y', '0');

    // Create y-axis
    var scale = d3.scaleLinear()
        .domain([min, max])
        .range([height, 0]);
    var v = [];
    for (let n = 0; n < 10; n++) {
        v.push(min + (n - 1) * ((max - min) / 9));
    }
    // console.log(v)
    var y_axis = d3.axisRight()
        .scale(scale)
        .tickSizeOuter(0);
    // .style('font-size', 14)

    group.append('g')
        .attr('class', 'y-axis')
        .attr('transform', 'translate(20, 10)')
        .call(y_axis)
        .style('font-size', 15);

    // Append a defs (for definition) element to your SVG
    var defs = group.append("defs");

    // Append a linearGradient element to the defs and give it a unique id
    var linearGradient = defs.append("linearGradient")
        .attr("id", "linear-gradient")
        .attr('x1', '0%') // bottom
        .attr('y1', '100%')
        .attr('x2', '0%') // to top
        .attr('y2', '0%')
        .attr('spreadMethod', 'pad');
    // A color scale
    var v = [];

    for (let ii = 0; ii <= 1; ii += 0.1) {
        v.push(d3.interpolateTurbo(ii));
    }
    var colorScale = d3.scaleLinear().range(v);

    //Append multiple color stops by using D3's data/enter step
    linearGradient.selectAll("stop")
        .data(colorScale.range())
        .enter().append("stop")
        .attr("offset", function (d, i) { return i / (colorScale.range().length - 1); })
        .attr("stop-color", function (d) { return d; });

    group.append('rect')
        .attr('x', '10')
        .attr('y', '10')
        .attr('width', width)
        .attr('height', height)
        .style('fill', 'url(#linear-gradient)');

};


//var ViewWafer = function (csvUrl, delimiter, selectorDiv, settings) {
var ViewWafer = function (sourceData, selectorDiv, settings) {
    // Sync with: TypeValidationLibrary / TypeValidator_EDX_CSV / edxMA420_0based
    let edxMA420_0based = [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255, 256, 257, 258, 259, 260, 261, 262, 263, 264, 265, 266, 267, 268, 269, 270, 271, 272, 274, 275, 276, 277, 278, 279, 280, 281, 282, 283, 284, 285, 286, 287, 288, 289, 290, 291, 292, 295, 296, 297, 298, 299, 300, 301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 311, 312, 313, 317, 318, 319, 320, 321, 322, 323, 324, 325, 326, 327, 328, 329, 330, 331, 332, 333, 339, 340, 341, 342, 343, 344, 345, 346, 347, 348, 349, 350, 351, 352, 353, 361, 362, 363, 364, 365, 366, 367, 368, 369, 370, 371, 372, 373, 383, 384, 385, 386, 387, 388, 389, 390, 391, 392, 393, 406, 407, 408, 409, 410, 411, 412];

    function Sanitize4DOM(st) {
        var res = "";
        for (let i = 0; i < st.length; i++) {
            if (st[i] >= '0' && st[i] <= '9' || st[i] >= 'a' && st[i] <= 'z' || st[i] >= 'A' && st[i] <= 'Z')
                res += st[i];
        }
        return res;
    }
//    d3.dsv(delimiter, csvUrl).then(function (sourceData) {    // columns: "Spectrum", "X (mm)", "Y (mm)", "Al", "Co", "Ni"
    let data = sourceData;
    for (let i = 0; i < data.columns.length; i++) {
        data.columns[i] = data.columns[i].trim();
    }
    const columnsTrim = data.columns.map(a => a);    // sometimes in UTF-8 files preable affects first column name
    let IndexColumnName = columnsTrim.includes("Spectrum") ? "Spectrum" : (columnsTrim.includes("Index") ? "Index" : (columnsTrim.includes("MA") ? "MA" : null));   // "Spectrum" / "Index" / "MA";

//console.log("data = ", data);
    //console.log("data.columns", data.columns);
//console.log(`data.columns[0].length = ${data.columns[0].length} [${data.columns[0]}]`);
    
    //console.log((data.columns[0].toLocaleString()) == "Index".toLocaleString());
//console.log('(data.columns[0].trim()) == "Index".trim()', (data.columns[0].trim()) == "Index".trim());
    //console.log("data.columns.includes('Index') = " + data.columns.includes("Index"));
    //console.log("0 IndexColumnName = " + IndexColumnName);
//    IndexColumnName = "Index";
        let XColumnName = data.columns.includes("X (mm)") ? "X (mm)" : (data.columns.includes("x") ? "x" : null);   // "X (mm)";
        let YColumnName = data.columns.includes("Y (mm)") ? "Y (mm)" : (data.columns.includes("y") ? "y" : null);   // "Y (mm)";
        let sliceColumns = 0;
        let skipElements = [];  // skip Elements (from Substrate) AND Normalize to 100% output

        if (settings && settings["IndexColumnName"])
            IndexColumnName = settings.IndexColumnName;
        if (settings && settings["XColumnName"])
            XColumnName = settings.XColumnName;
        if (settings && settings["YColumnName"])
            YColumnName = settings.YColumnName;
        if (settings && settings["skipElements"])
            skipElements = settings.skipElements;

        if (IndexColumnName != null) sliceColumns++;
        if (XColumnName != null) sliceColumns++;
        if (YColumnName != null) sliceColumns++;

//console.log("1 IndexColumnName = " + IndexColumnName);
        if (data.columns.includes("In stats."))
            sliceColumns++;
        if (settings && settings["sliceColumns"])       // redefining sliceColumns!!!
            sliceColumns = settings.sliceColumns;

        //get all element names
        //console.log(data);
        // console.log("waferCoords342" + waferCoords342);
        let eles = Object.keys(data[0]).slice(sliceColumns);     // "Al", "Co", "Ni"

        // delete substrate elements (skipElements)
        const intersection = eles.filter(v => skipElements.includes(v));
        const intersectionElements = eles.filter(v => chemicalElements.includes(v));
        const coef = intersectionElements.length > 0 ? 100 : 1;
        if (intersection.length > 0) {
            eles = eles.filter(v => !intersection.includes(v) && v!="");
            data.columns = data.columns.filter(v => !intersection.includes(v));
            for (let idx = 0; idx < data.length; idx++) {
                let sum = 0;
                for (let [i, ele] of eles.entries()) {  // get sum
                    sum += parseFloat(data[idx][ele]);
                }

                for (let [i, ele] of eles.entries()) {  // normalize all elements containtment
                    if (sum>0)
                        data[idx][ele] = (parseFloat(data[idx][ele]) / sum * coef).toFixed(2);
                    else
                        data[idx][ele] = 0;
                }

                for (let i = 0; i < intersection.length; i++) { // delete substrate elelements
                    delete data[idx][intersection[i]];
                }
            }
        }

        d3.select(selectorDiv).selectAll("*").remove();
        const div = d3.select(selectorDiv)
            .append('div')
        // .attr('width', '100%')
        //tooltip
        const tooltip = d3.select(selectorDiv).append('div')
            .style('opacity', '0').style('position', 'absolute')
            .style('background-color', 'FloralWhite')
            .style('stroke', 'black');

        const maxX = Math.max.apply(Math, data.map(a => parseFloat(a[XColumnName])));    // 0 %
        const factor = maxX>100 ? 1000 : 1;
        // define x and y axis
        const x = d3.scaleLinear().domain([-50*factor, 50*factor]).range([0, 300]);
        const y = d3.scaleLinear().domain([-50*factor, 50*factor]).range([300, 0]);

        var dataFiltered = data;
        if (data.length == 420) {   // filter out to standard grid
            dataFiltered = data.filter(
                (v, index) => edxMA420_0based.includes(index)
            );
        } else if (data.length > 342 && IndexColumnName != null && data[0][IndexColumnName].indexOf('{') > 0 && data[0][IndexColumnName].indexOf('}') > 0) {
            // leave only 342 MA grid (filter out outliers)
            dataFiltered = data.filter(
                function (v, index) {
                    let i = v[IndexColumnName].indexOf('{');
                    let e = v[IndexColumnName].indexOf('}');
                    let idx = parseInt(v[IndexColumnName].substring(i + 1, e));
                    return edxMA420_0based.includes(idx - 1);   // zero-based index
                }
            );
        }

        for (let [i, ele] of eles.entries()) {
            if (ele == "")
                continue;
            // add main group
            var svg = div.append('svg')
                .attr('transform', 'translate(0,50)')
                .datum({ x: i < 3 ? 0 * i : 370 * (i - 3), y: i < 3 ? 0 : 350 })
                .attr('width', 360)
                .attr('height', 350)
                .call(d3.drag()
                    .on('drag', function (event, d) {
                        d3.select(this)
                            .attr('transform', `translate(${d.x = event.x}, ${d.y = event.y})`)
                    }))

            var group = svg.append('g')
                .attr('class', 'g_' + Sanitize4DOM(ele))
            // .attr('transform', `translate(${i<3?360*i:360*(i-3)}, ${i<3?0:330})`)

            // define color
            const min = Math.min.apply(Math, dataFiltered.map(a => a[ele]));    // 0 %
            const max = Math.max.apply(Math, dataFiltered.map(a => a[ele]));    // 100 %
            const mycolor = d3.scaleSequential().domain([min, max]).interpolator(d3.interpolateTurbo);

            //console.log("min = " + min);
            //console.log("max = " + max);



            // add title to main group
            group.append('text')
                .text(`${ele}: ${min} - ${max}` + (intersectionElements.length > 0 ? ' %' : ''))
                .attr('x', '50%').attr('y', '12').attr('dominant-baseline', 'middle').attr('text-anchor', 'middle');

            // add rect to rect_group
            var last_click_rects = [];
            var last_click_colors = [];

            const rect_group = group.append('g')
                .attr('id', 'rectgroup_' + Sanitize4DOM(ele))
                .attr('transform', `translate(0, 12)`)

            rect_group.append('g')
                .attr("style", "outline: thin solid black;")
                .selectAll('rect_' + Sanitize4DOM(ele))
                .data(dataFiltered)
                .enter().append('rect')
                .attr('class', (d, index) => 'rect_' + index)
                //.attr('x', function (d) { return x(d.x) })
                .attr('x', (d, index) => XColumnName == null ? x(waferCoords342[index].x) : x(d[XColumnName]))      // X coordinate (calculated)
                .attr('data-x', (d, index) => XColumnName == null ? waferCoords342[index].x : d[XColumnName])                           // X coordinate (from data)
                //.attr('y', function (d) { return y(d.y) })
                .attr('y', (d, index) => YColumnName == null ? y(waferCoords342[index].y) : y(d[YColumnName]))      // Y coordinate (calculated)
                .attr('data-y', (d, index) => YColumnName == null ? waferCoords342[index].y : d[YColumnName])                           // Y coordinate (from data)
                .attr('data-name', (d, index) => IndexColumnName == null ? `row_${index + 1}` : d[IndexColumnName])     // Name (of Measurement Area, from data)
                .attr('width', 13)
                .attr('height', 13)
                .style('fill', d => { return mycolor(d[ele]) })         // background Color
                .style('stroke', 'white')                               // border
                .on('click', function (event, d) {      // TOOLTIP:
                    tooltip.style('opacity', '1')                       // non-transparent
                        .style('border', '1px solid blue')
                        .style('padding', '3px 9px')
                        .style('left', event.pageX + 8 + 'px')
                        .style('top', event.pageY + 8 + 'px')

                    // console.log(last_click_rects.length)
                    if (last_click_rects.length > 0) {                  // deselect -> revert to initial state
                        for (let [i, rect] of last_click_rects.entries()) {
                            rect.style.fill = last_click_colors[i];
                            rect.style.stroke = 'white';
                        }
                        last_click_rects = [];
                        last_click_colors = [];
                    }
                    // console.log(d3.select(this))

                    const click_class = `${selectorDiv} .${d3.select(this).attr('class')}`;

                    for (let rect of d3.selectAll(click_class)) {
                        last_click_rects.push(rect);
                        last_click_colors.push(rect.style.fill);
                    }
                    //d3.selectAll(click_class).style('fill', 'white').style('stroke', 'blue');
                    d3.selectAll(click_class).style('stroke', 'red');//.style('stroke-width', '2');     // select => highlight

                    const pos = parseInt(d3.select(this).attr('class').replace('rect_', ''));
                    const dx = d3.select(this).attr('data-x');
                    const dy = d3.select(this).attr('data-y');
                    const name = d3.select(this).attr('data-name');
                    var ele_text = '';
                    var k = Object.keys(dataFiltered[pos]).slice(sliceColumns);    // keys
                    var v = Object.values(dataFiltered[pos]).slice(sliceColumns);  // values
                    // console.log(Object.entries(data[pos]))

                    for (let i = 0; i < k.length; i++) {
                        if (k[i] == "") continue;
                        if (ele_text != "")
                            ele_text += "; ";
                        ele_text += '<b>' + k[i] + '</b>: ' + v[i] + (intersectionElements.length > 0 ? '%' : '');
                    }

                    tooltip.html(`Position ${pos + 1} [${dx}; ${dy}]: ` + name + '<br/>' + ele_text);

                })
            // add color legend
            colorLegend(selectorDiv + ' #rectgroup_' + Sanitize4DOM(ele), 300, 20, 10, 250, min, max,
                intersectionElements.length > 0
            );
        }
    //});
}
// ===================== Bin's wafer plot (EDX) ======================== - END
