const price = () => {
  const priceInput = document.getElementById("item-price");
  if (!priceInput) return;

  priceInput.addEventListener("input", () => {
    const inputValue = priceInput.value;
    const addTaxDom = document.getElementById("add-tax-price");
    const profitDom = document.getElementById("profit");

    if (inputValue >= 300 && inputValue <= 9999999) {
      const fee = Math.floor(inputValue * 0.1);
      const profit = Math.floor(inputValue - fee);
      addTaxDom.innerHTML = Math.floor(fee);
      profitDom.innerHTML = Math.floor(profit);
    } else {
      addTaxDom.innerHTML = "";
      profitDom.innerHTML = "";
    }
  })
};

window.addEventListener("turbo:load", price);
window.addEventListener("turbo:render", price);
