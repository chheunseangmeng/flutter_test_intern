const express = require('express');
const cors = require('cors');
const db = require('../config/db'); // Assuming db is MySQL connection

const app = express();
const port = 5000;

// Middleware
app.use(cors());
app.use(express.json());

// Helper to ensure numeric price
const ensureNumericPrice = (price) => {
  if (typeof price === 'number') return price;
  if (typeof price === 'string') return parseFloat(price.replace(',', '.'));
  throw new Error('Invalid price format');
};

// GET /products or /products?id=123
exports.handleGetProducts = async (req, res) => {
  try {
    const { id, page = 1, itemsPerPage = 10, search = '', sort = 'name_asc' } = req.query;
    const pageNum = parseInt(page);
    const itemsPerPageNum = parseInt(itemsPerPage);

    if (id) {
      const [rows] = await db.query('SELECT * FROM products WHERE productId = ?', [id]);
      if (rows.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'Product not found',
          data: null,
        });
      }

      return res.status(200).json({
        success: true,
        data: {
          productId: rows[0].productId,
          productName: rows[0].productName,
          price: ensureNumericPrice(rows[0].price),
          stock: rows[0].stock,
        },
      });
    } else {
      // Build query for pagination, search, and sort
      let query = 'SELECT * FROM products';
      const params = [];

      // Search by productName
      if (search) {
        query += ' WHERE productName LIKE ?';
        params.push(`%${search}%`);
      }

      // Sorting
      let sortField = 'productName';
      let sortOrder = 'ASC';
      if (sort === 'name_desc') {
        sortField = 'productName';
        sortOrder = 'DESC';
      } else if (sort === 'price_asc') {
        sortField = 'price';
        sortOrder = 'ASC';
      } else if (sort === 'price_desc') {
        sortField = 'price';
        sortOrder = 'DESC';
      } else if (sort === 'stock_asc') {
        sortField = 'stock';
        sortOrder = 'ASC';
      } else if (sort === 'stock_desc') {
        sortField = 'stock';
        sortOrder = 'DESC';
      }
      query += ` ORDER BY ${sortField} ${sortOrder}`;

      // Pagination
      query += ' LIMIT ? OFFSET ?';
      params.push(itemsPerPageNum, (pageNum - 1) * itemsPerPageNum);

      // Execute query
      const [rows] = await db.query(query, params);

      // Get total items for pagination
      const [countResult] = await db.query(
        `SELECT COUNT(*) as totalItems FROM products${search ? ' WHERE productName LIKE ?' : ''}`,
        search ? [`%${search}%`] : []
      );
      const totalItems = countResult[0].totalItems;

      const products = rows.map(row => ({
        productId: row.productId,
        productName: row.productName,
        price: ensureNumericPrice(row.price),
        stock: row.stock,
      }));

      return res.status(200).json({
        success: true,
        data: products,
        totalItems,
      });
    }
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message,
      data: null,
    });
  }
};

// POST /products
exports.createProduct = async (req, res) => {
  try {
    const { productName, price, stock } = req.body;
    const numericPrice = ensureNumericPrice(price);

    if (!productName || numericPrice === undefined || stock === undefined) {
      return res.status(400).json({
        success: false,
        message: 'All fields are required',
        data: null,
      });
    }

    if (numericPrice <= 0 || stock <= 0) {
      return res.status(400).json({
        success: false,
        message: 'Price and stock must be positive values',
        data: null,
      });
    }

    const [result] = await db.query(
      'INSERT INTO products (productName, price, stock) VALUES (?, ?, ?)',
      [productName, numericPrice, stock]
    );

    return res.status(201).json({
      success: true,
      data: {
        productId: result.insertId,
        productName,
        price: numericPrice,
        stock,
      },
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message,
      data: null,
    });
  }
};

// PUT /products?id=1
exports.updateProduct = async (req, res) => {
  try {
    const { id } = req.query;
    const { productName, price, stock } = req.body;
    const numericPrice = ensureNumericPrice(price);

    if (!id) {
      return res.status(400).json({ success: false, message: 'Product ID required', data: null });
    }

    if (!productName || numericPrice === undefined || stock === undefined) {
      return res.status(400).json({
        success: false,
        message: 'All fields are required',
        data: null,
      });
    }

    if (numericPrice <= 0 || stock <= 0) {
      return res.status(400).json({
        success: false,
        message: 'Price and stock must be positive values',
        data: null,
      });
    }

    const [result] = await db.query(
      'UPDATE products SET productName = ?, price = ?, stock = ? WHERE productId = ?',
      [productName, numericPrice, stock, id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: 'Product not found',
        data: null,
      });
    }

    return res.status(200).json({
      success: true,
      data: {
        productId: parseInt(id),
        productName,
        price: numericPrice,
        stock,
      },
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message,
      data: null,
    });
  }
};


// DELETE /products?id=123
exports.deleteProduct = async (req, res) => {
  try {
    const { id } = req.query;
    if (!id) {
      return res.status(400).json({ success: false, message: 'Product ID required', data: null });
    }

    const [result] = await db.query('DELETE FROM products WHERE productId = ?', [id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: 'Product not found',
        data: null,
      });
    }

    return res.status(200).json({
      success: true,
      data: null,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message,
      data: null,
    });
  }
};