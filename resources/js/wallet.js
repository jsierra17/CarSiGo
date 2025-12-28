// Simple wallet UI helper using axios
const el = document.getElementById('wallet-app');
if (el) {
    const tokenInput = document.getElementById('wallet-token');
    const balanceEl = document.getElementById('wallet-balance');
    const statusEl = document.getElementById('wallet-status');
    const historyEl = document.getElementById('wallet-history');
    const recargaForm = document.getElementById('wallet-recarga-form');

    function authHeaders() {
        const t = tokenInput.value.trim();
        return t ? { Authorization: `Bearer ${t}` } : {};
    }

    async function loadBalance() {
        try {
            const res = await axios.get('/api/wallet/balance', { headers: authHeaders() });
            if (res.data && res.data.success !== false) {
                balanceEl.textContent = (res.data.balance ?? res.data.data?.balance) + ' COP';
                statusEl.textContent = res.data.status ?? (res.data.data?.status ?? 'unknown');
            } else {
                balanceEl.textContent = 'Error';
                statusEl.textContent = res.data.message || 'error';
            }
        } catch (err) {
            balanceEl.textContent = 'Error';
            statusEl.textContent = err.response?.data?.message || err.message;
        }
    }

    async function loadHistory() {
        try {
            const res = await axios.get('/api/wallet/historial', { headers: authHeaders() });
            historyEl.innerHTML = '';
            if (res.data && Array.isArray(res.data.data || res.data)) {
                const items = res.data.data || res.data;
                items.forEach(tx => {
                    const li = document.createElement('li');
                    li.textContent = `${tx.created_at || tx.date || ''} — ${tx.type || tx.descripcion || ''} — ${tx.amount ?? tx.monto}`;
                    historyEl.appendChild(li);
                });
            } else {
                historyEl.textContent = 'No history or permission denied';
            }
        } catch (err) {
            historyEl.textContent = err.response?.data?.message || err.message;
        }
    }

    if (document.getElementById('wallet-refresh')) {
        document.getElementById('wallet-refresh').addEventListener('click', (e) => {
            e.preventDefault();
            loadBalance();
            loadHistory();
        });
    }

    if (recargaForm) {
        recargaForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            const amount = recargaForm.querySelector('[name="amount"]').value;
            const reference = recargaForm.querySelector('[name="reference"]').value;
            try {
                const res = await axios.post('/api/wallet/recargar', { amount, reference }, { headers: authHeaders() });
                alert(res.data.message || 'Recarga iniciada');
            } catch (err) {
                alert(err.response?.data?.message || err.message);
            }
        });
    }

    // initial load
    loadBalance();
    loadHistory();
}
