const express = require('express');
const router = express.Router();
const productController = require('../controllers/productController');

// Routes seperate
router.get('/', productController.handleGetProducts);
router.post('/', productController.createProduct);
router.put('/', productController.updateProduct);
router.delete('/', productController.deleteProduct);

module.exports = router;