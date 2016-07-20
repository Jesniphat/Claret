console.log("Donate Script")

function linkToCollection() {
    console.log("Link");
    $('<form>').append(H2G.postedData($("#data").H2GFill({ donateAction: "new", donateId:"0"}))).H2GFill({ action: "Collection.aspx", method: "post" }).submit();
}