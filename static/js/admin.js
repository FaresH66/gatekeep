// Logout
document.getElementById('logoutBtn')?.addEventListener('click', () => {
    localStorage.removeItem('token');
    window.location.href = '/';
});

// Load users
async function loadUsers() {
    const token = localStorage.getItem('token');
    try {
        const response = await fetch('/api/admin/users', {
            headers: { 'Authorization': `Bearer ${token}` }
        });
        const data = await response.json();
        if (response.ok) {
            const userList = document.getElementById('userList');
            userList.innerHTML = data.users.map(user => `
                <li class="py-2">${user.name} (${user.email}) - ${user.role}</li>
            `).join('');
        } else {
            alert(data.message);
        }
    } catch (error) {
        alert('Error loading users');
    }
}

// Add user
document.getElementById('addUserForm')?.addEventListener('submit', async (e) => {
    e.preventDefault();
    const token = localStorage.getItem('token');
    const name = document.getElementById('newName').value;
    const email = document.getElementById('newEmail').value;
    const password = document.getElementById('newPassword').value;
    const role = document.getElementById('newRole').value;

    try {
        const response = await fetch('/api/admin/users', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`
            },
            body: JSON.stringify({ name, email, password, role })
        });
        const data = await response.json();
        alert(data.message);
        if (response.ok) loadUsers(); // Refresh user list
    } catch (error) {
        alert('Error adding user');
    }
});

// Assign car
document.getElementById('assignCarForm')?.addEventListener('submit', async (e) => {
    e.preventDefault();
    const token = localStorage.getItem('token');
    const residentId = document.getElementById('residentId').value;
    const licensePlate = document.getElementById('licensePlate').value;

    try {
        const response = await fetch('/api/admin/cars', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`
            },
            body: JSON.stringify({ resident_id: residentId, license_plate: licensePlate })
        });
        const data = await response.json();
        alert(data.message);
    } catch (error) {
        alert('Error assigning car');
    }
});

// Load logs
document.getElementById('loadLogsBtn')?.addEventListener('click', async () => {
    const token = localStorage.getItem('token');
    try {
        const response = await fetch('/api/admin/logs', {
            headers: { 'Authorization': `Bearer ${token}` }
        });
        const data = await response.json();
        if (response.ok) {
            const logList = document.getElementById('logList');
            logList.innerHTML = data.logs.map(log => `
                <li class="py-2">${log.timestamp}: ${log.event_type} (User ${log.user_id}) - ${JSON.stringify(log.details)}</li>
            `).join('');
        } else {
            alert(data.message);
        }
    } catch (error) {
        alert('Error loading logs');
    }
});

// Load users on page load
document.addEventListener('DOMContentLoaded', loadUsers);