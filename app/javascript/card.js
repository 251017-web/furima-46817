const pay = () => {
    const publicKey = document.querySelector("meta[name='payjp-public-key']");
    if (!publicKey) return;
    const form = document.getElementById('charge-form');
    if (!form) return;
    if (form.dataset.payjpInitialized === 'true') return;
    form.dataset.payjpInitialized = 'true';
    const errorArea = document.getElementById('card-error-message');
    const showError = (message) => {
        if (errorArea) errorArea.textContent = message;
    };
    const clearError = () => {
        if (errorArea) errorArea.textContent = '';
    };
    const submitWithoutToken = () => {
        form.dataset.skipPayjp = 'true';
        form.requestSubmit();
    };
    const syncPlaceholder = (element, wrapperId) => {
        const wrapper = document.getElementById(wrapperId);
        if (!wrapper) return;

        if (typeof element.on !== 'function') return;

        element.on('focus', () => {
            wrapper.classList.add('is-focused');
        });

        element.on('blur', () => {
            wrapper.classList.remove('is-focused');
        });

        element.on('change', (event) => {
            if (event.empty) {
                wrapper.classList.remove('has-value');
            } else {
                wrapper.classList.add('has-value');
            }
        });
    };
    const key = publicKey.getAttribute("content");
    if (!key || key.endsWith('xxxxx')) {
        showError('PAY.JP公開鍵が未設定です。環境変数を確認してください。');
        return;
    }

    const payjp = Payjp(key);
    const elements = payjp.elements();
    const style = {
        base: {
            fontSize: '16px',
            color: '#222',
            '::placeholder': {
                color: 'transparent'
            }
        }
    };
    const numberElement = elements.create('cardNumber', {
        style: style,
        placeholder: ''
    });
    const expiryElement = elements.create('cardExpiry', {
        style: style,
        placeholder: ''
    });
    const cvcElement = elements.create('cardCvc', {
        style: style,
        placeholder: ''
    });

    numberElement.mount('#number-form');
    expiryElement.mount('#expiry-form');
    cvcElement.mount('#cvc-form');
    syncPlaceholder(numberElement, 'number-form-wrap');
    syncPlaceholder(expiryElement, 'expiry-form-wrap');
    syncPlaceholder(cvcElement, 'cvc-form-wrap');

    form.addEventListener("submit", (e) => {
        if (form.dataset.skipPayjp === 'true') {
            delete form.dataset.skipPayjp;
            return;
        }

        e.preventDefault();
        clearError();
        payjp.createToken(numberElement).then(function (response) {
            if (response.error) {
                submitWithoutToken();
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
            submitWithoutToken();
        });
    });
};

window.addEventListener("turbo:load", pay);
window.addEventListener("turbo:render", pay);
