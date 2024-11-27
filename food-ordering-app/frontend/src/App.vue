<!-- frontend/src/App.vue -->
<template>
  <div id="app">
    <h1>Food Ordering App</h1>

    <!-- Error Message Display -->
    <div v-if="errorMessage" class="error-message">
      {{ errorMessage }}
    </div>

    <!-- Loading Indicator -->
    <div v-if="isLoading" class="loading">
      Loading menu items...
    </div>

    <div v-else-if="menuItems.length > 0" class="menu">
      <div v-for="item in menuItems" :key="item.id" class="menu-item">
        <h3>{{ item.name }}</h3>
        <p>{{ item.description }}</p>
        <p>Price: ${{ Number(item.price).toFixed(2) }}</p>
        <div class="order-controls">
          <button @click="decreaseQuantity(item)">-</button>
          <span>{{ calculateItemQuantity(item) }}</span>
          <button @click="increaseQuantity(item)">+</button>
        </div>
      </div>
    </div>
    <div v-else class="no-items">
      No menu items available
    </div>

    <div class="cart">
      <h2>Cart</h2>
      <div v-for="item in cartItems" :key="item.id" class="cart-item">
        {{ item.name }} - Quantity: {{ item.quantity }} - ${{ (Number(item.price) * item.quantity).toFixed(2) }}
      </div>
      <p>Total: ${{ calculateTotal }}</p>
      <button @click="placeOrder" :disabled="cartItems.length === 0">Place Order</button>
    </div>
  </div>
</template>

<script>
import { ref, onMounted, computed } from 'vue';
import axios from 'axios';

export default {
  setup() {
    // Reactive state
    const menuItems = ref([]);
    const cartItems = ref([]);
    const errorMessage = ref('');
    const isLoading = ref(true);

    // Fetch menu items with extensive error handling
    const fetchMenuItems = async () => {
      // Reset states
      errorMessage.value = '';
      isLoading.value = true;

      try {
        // Log the full URL being called
        const apiUrl = import.meta.env.VITE_API_URL;
        console.log('Attempting to fetch menu from:', apiUrl + '/menu');

        // Detailed axios configuration
        const response = await axios.get(`${apiUrl}/menu`, {
          timeout: 5000, // 5 second timeout
          headers: {
            'Accept': 'application/json'
          }
        });

        console.log('Full response:', response);
        console.log('Response data:', response.data);

        // Validate response
        if (!response.data || !Array.isArray(response.data)) {
          throw new Error('Invalid response format');
        }

        // Map menu items with additional safety
        menuItems.value = response.data.map(item => ({
          id: item.id,
          name: item.name || 'Unnamed Item',
          description: item.description || 'No description',
          price: Number(item.price) || 0,
          quantity: 0
        }));

        // Log mapped items
        console.log('Mapped menu items:', menuItems.value);

        // Handle empty menu
        if (menuItems.value.length === 0) {
          errorMessage.value = 'No menu items found';
        }
      } catch (error) {
        // Comprehensive error logging
        console.error('Fetch menu error:', error);

        // Detailed error message
        if (error.response) {
          // The request was made and the server responded with a status code
          errorMessage.value = `Server Error: ${error.response.status} - ${error.response.data.message || 'Unknown error'}`;
        } else if (error.request) {
          // The request was made but no response was received
          errorMessage.value = 'No response from server. Please check your connection.';
        } else {
          // Something happened in setting up the request
          errorMessage.value = `Error: ${error.message}`;
        }
      } finally {
        // Always set loading to false
        isLoading.value = false;
      }
    };

    // Calculate total
    const calculateTotal = computed(() => {
      return cartItems.value.reduce((total, item) => total + (Number(item.price) * item.quantity), 0).toFixed(2);
    });

    // Calculate item quantity in cart
    const calculateItemQuantity = (item) => {
      const cartItem = cartItems.value.find(ci => ci.id === item.id);
      return cartItem ? cartItem.quantity : 0;
    };

    // Increase quantity
    const increaseQuantity = (item) => {
      console.log('Increasing quantity for:', item);

      // Find existing cart item
      const existingCartItem = cartItems.value.find(ci => ci.id === item.id);

      if (existingCartItem) {
        // If item exists, increase quantity
        existingCartItem.quantity++;
      } else {
        // If item not in cart, add it
        cartItems.value.push({
          ...item,
          quantity: 1
        });
      }
    };

    // Decrease quantity
    const decreaseQuantity = (item) => {
      console.log('Decreasing quantity for:', item);

      // Find the item in cart
      const cartItemIndex = cartItems.value.findIndex(ci => ci.id === item.id);

      if (cartItemIndex !== -1) {
        // Decrease quantity
        cartItems.value[cartItemIndex].quantity--;

        // Remove if quantity reaches 0
        if (cartItems.value[cartItemIndex].quantity === 0) {
          cartItems.value.splice(cartItemIndex, 1);
        }
      }
    };

    // Place order
    const placeOrder = async () => {
      try {
        const orderItems = cartItems.value.map(item => ({
          id: item.id,
          price: item.price,
          quantity: item.quantity
        }));

        await axios.post(`${import.meta.env.VITE_API_URL}/order`, { items: orderItems });
        alert('Order placed successfully!');
        cartItems.value = [];
      } catch (error) {
        console.error('Error placing order:', error);
        alert('Failed to place order');
      }
    };

    // Fetch menu items when component mounts
    onMounted(() => {
      fetchMenuItems();
    });

    // Return methods and state for template use
    return {
      menuItems,
      cartItems,
      errorMessage,
      isLoading,
      calculateTotal,
      calculateItemQuantity,
      increaseQuantity,
      decreaseQuantity,
      placeOrder
    };
  }
};
</script>

<style scoped>
/* Previous styles remain the same */
.error-message {
  background-color: #ffdddd;
  color: red;
  padding: 10px;
  margin-bottom: 15px;
  border-radius: 5px;
}
.loading {
  text-align: center;
  padding: 20px;
  color: #666;
}
.no-items {
  text-align: center;
  color: #999;
  padding: 20px;
}
.order-controls {
  display: flex;
  align-items: center;
  justify-content: center;
}
.order-controls button {
  margin: 0 10px;
  padding: 5px 10px;
  background-color: #f0f0f0;
  border: 1px solid #ddd;
  cursor: pointer;
}
.order-controls span {
  margin: 0 10px;
}
</style>
