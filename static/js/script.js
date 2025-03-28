document.getElementById('loginForm').addEventListener('submit', async (e) => {
    e.preventDefault();

    const email = document.getElementById('email').value;
    const password = document.getElementById('password').value;
    const messageEl = document.getElementById('message');

    try {
        const response = await fetch('/api/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email, password }),
        });

        const data = await response.json();
        messageEl.textContent = data.message;
        messageEl.classList.remove('hidden');

        if (response.ok) {
            messageEl.classList.remove('text-red-500');
            messageEl.classList.add('text-green-500');
            localStorage.setItem('token', data.token); // Store JWT in localStorage
            console.log(`Logged in as ${data.role} (ID: ${data.user_id})`);
            setTimeout(() => {
                if (data.role === 'admin') window.location.href = '/admin';
                else if (data.role === 'gatekeeper') window.location.href = '/gatekeeper';
                else if (data.role === 'resident') window.location.href = '/resident';
            }, 1000);
        } else {
            messageEl.classList.add('text-red-500');
        }
    } catch (error) {
        messageEl.textContent = 'An error occurred';
        messageEl.classList.remove('hidden');
        messageEl.classList.add('text-red-500');
    }s

    // Example: Test protected route (uncomment to try)
    // const token = localStorage.getItem('token');
    // const protectedResponse = await fetch('/api/protected', {
    //     headers: { 'Authorization': `Bearer ${token}` }
    // });
    // console.log(await protectedResponse.json());
});