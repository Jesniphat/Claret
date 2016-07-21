console.log("Donate Script")

function linkToCollection() {
    console.log("Link");
    $('<form>').append(H2G.postedData($("#data").H2GFill({ donateAction: "new", donateId:"0"}))).H2GFill({ action: "Collection.aspx", method: "post" }).submit();
}

function getDonateTypeList() {
    // console.log("getDonateTypeList");
    $.ajax({
        url: '../../ajaxAction/donateAction.aspx',
        data: H2G.ajaxData({ action: 'getDonateTypeList' }).config,
        type: "POST",
        dataType: "json",
        error: function (xhr, s, err) {
            console.log(s, err);
        },
        success: function (data) {
            console.log("Respondata = ", data);
            if (data.length > 0) {
                console.log("Respondata = ", data);
            }
        }
    });

}