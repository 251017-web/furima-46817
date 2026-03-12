const pay = () => {
    const publicKey = document.querySelector("meta[name='payjp-public-key']");
    if (!publicKey) return;
    const form = document.getElementById('charge-form');
    if (!form) return;
    const errorArea = document.getElementById('card-error-message');
    const showError = (message) => {
        if (errorArea) errorArea.textContent = message;
    };
    const clearError = () => {
        if (errorArea) errorArea.textContent = '';
    };
    const key = publicKey.getAttribute("content");
    if (!key || key.endsWith('xxxxx')) {
        showError('PAY.JP公開鍵が未設定です。環境変数を確認してください。');
        return;
    }

    const payjp = Payjp(key);
    const elements = payjp.elements();
    const numberElement = elements.create('cardNumber');
    const expiryElement = elements.create('cardExpiry');
    const cvcElement = elements.create('cardCvc');

    numberElement.mount('#number-form');
    expiryElement.mount('#expiry-form');
    cvcElement.mount('#cvc-form');

    form.addEventListener("submit", (e) => {
        e.preventDefault();
        clearError();
        payjp.createToken(numberElement).then(function (response) {
            if (response.error) {
                showError(response.error.message || 'カード情報のトークン化に失敗しました。');
            } else {
                const token = response.id;
                const renderDom = document.getElementById("charge-form");

                // 既存のtoken inputを削除して二重送信を防止
                const existingToken = document.getElementById("card-token");
                if (existingToken) existingToken.remove();

                const tokenObj = `<input value=${token} name='token' type="hidden" id="card-token">`;
                renderDom.insertAdjacentHTML("beforeend", tokenObj);
                document.getElementById("charge-form").submit();
            }
        }).catch(function () {
            showError('カード情報の送信中にエラーが発生しました。');
        });
    });
};

window.addEventListener("turbo:load", pay);
window.addEventListener("turbo:render", pay);
