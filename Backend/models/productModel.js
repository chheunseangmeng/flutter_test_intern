const db = require('../config/db');

class Product {
  static async getAll() {
    const [rows] = await db.query('SELECT * FROM products');
    return rows;
  }

  static async getById(id) {
    const [rows] = await db.query('SELECT * FROM products WHERE productId = ?', [id]);
    return rows[0];
  }

  static async create(product) {
    const { productName, price, stock } = product;
    const [result] = await db.query(
      'INSERT INTO products (productName, price, stock) VALUES (?, ?, ?)',
      [productName, price, stock]
    );
    return { productId: result.insertId, ...product };
  }

  static async update(id, product) {
    const { productName, price, stock } = product;
    await db.query(
      'UPDATE products SET productName = ?, price = ?, stock = ? WHERE productId = ?',
      [productName, price, stock, id]
    );
    return { productId: id, ...product };
  }

  static async delete(id) {
    await db.query('DELETE FROM products WHERE productId = ?', [id]);
    return true;
  }
}

module.exports = Product;