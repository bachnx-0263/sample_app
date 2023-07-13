$("#micropost_image").bind("change", async function() {
  var size_in_megabytes = this.files[0].size/1024/1024;
  if (size_in_megabytes > 5) {
    await alert(I18n.t("micropost.oversize"));
    this.value = null;
  }
});
