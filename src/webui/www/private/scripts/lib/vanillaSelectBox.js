vanillaSelectBox.prototype.disable = function () {
    this.main.addEventListener("click", function (e) {
        e.preventDefault();
        e.stopPropagation();
    });
    let already = document.getElementById("btn-group-" + this.rootToken);
    if (already) {
        let button = already.querySelector("button");
        if (button) button.classList.add("disabled");
        this.isDisabled = true;
    }
}

vanillaSelectBox.prototype.enable = function () {
    let already = document.getElementById("btn-group-" + this.rootToken);
    if (already) {
        let button = already.querySelector("button");
        if (button) button.classList.remove("disabled");
        this.isDisabled = false;
    }
} 