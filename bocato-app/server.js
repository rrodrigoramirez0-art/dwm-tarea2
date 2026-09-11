const express = require('express');
const { ApolloServer, gql } = require('apollo-server-express');
const cors = require('cors');
const path = require('path');

// Datos simulados en memoria (Sustituye temporalmente a MongoDB)
let sandwiches = [
  { id: "1", nombre: "Sánguche Italiano Tradicional", precio: 5500, descripcion: "Carne, tomate, palta y mayonesa", disponible: true },
  { id: "2", nombre: "Chacarero Bocato", precio: 6000, descripcion: "Carne, porotos verdes, tomate y ají verde", disponible: true },
  { id: "3", nombre: "Barros Luco Especial", precio: 5800, descripcion: "Carne a la plancha y queso derretido", disponible: true }
];

// 1. Schema GraphQL (typeDefs)
const typeDefs = gql`
  type Sandwich {
    id: ID!
    nombre: String!
    precio: Int!
    descripcion: String
    disponible: Boolean
  }

  type Alert {
    message: String
  }

  input SandwichInput {
    nombre: String!
    precio: Int!
    descripcion: String
    disponible: Boolean
  }

  type Query {
    getSandwiches: [Sandwich]
    getSandwichById(id: ID!): Sandwich
  }

  type Mutation {
    addSandwich(input: SandwichInput): Sandwich
    updSandwich(id: ID!, input: SandwichInput): Sandwich
    delSandwich(id: ID!): Alert
  }
`;

// 2. Resolvers usando la lista local
const resolvers = {
  Query: {
    getSandwiches: () => sandwiches,
    getSandwichById: (_, { id }) => sandwiches.find(s => s.id === id) || null
  },
  Mutation: {
    addSandwich: (_, { input }) => {
      const nuevo = { id: String(sandwiches.length + 1), ...input };
      sandwiches.push(nuevo);
      return nuevo;
    },
    updSandwich: (_, { id, input }) => {
      const index = sandwiches.findIndex(s => s.id === id);
      if (index === -1) return null;
      sandwiches[index] = { ...sandwiches[index], ...input };
      return sandwiches[index];
    },
    delSandwich: (_, { id }) => {
      sandwiches = sandwiches.filter(s => s.id !== id);
      return { message: "Sánguche eliminado correctamente" };
    }
  }
};

// 3. Inicialización del Servidor
async function startServer() {
  const app = express();
  app.use(cors());

  // Servir archivos estáticos
  app.use(express.static(path.join(__dirname, 'public')));

  const server = new ApolloServer({ typeDefs, resolvers });
  await server.start();
  server.applyMiddleware({ app });

  const PORT = 4000;
  app.listen(PORT, () => {
    console.log(`Servidor en ejecución en: http://localhost:${PORT}`);
    console.log(`GraphQL Playground en: http://localhost:${PORT}${server.graphqlPath}`);
  });
}

startServer();