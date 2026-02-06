# 📊 Diagrama de Base de Datos - CositApp

## Esquema de Relaciones

```
┌─────────────────┐
│    CLIENTE      │
│─────────────────│
│ id (PK)         │
│ nombre          │
│ telefono        │
│ email           │
│ direccion       │
│ notas           │
│ fecha_registro  │
│ activo          │
└─────────────────┘
        │
        │ 1:N
        ├──────────────────────────────────────┐
        │                                      │
        ▼                                      ▼
┌─────────────────┐                  ┌─────────────────┐
│    FAMILIAR     │                  │     PEDIDO      │
│─────────────────│                  │─────────────────│
│ id (PK)         │                  │ id (PK)         │
│ cliente_id (FK) │                  │ cliente_id (FK) │
│ nombre          │                  │ fecha_pedido    │
│ fecha_nacimiento│                  │ fecha_entrega   │
│ parentesco      │                  │ estado          │
│ notas           │                  │ precio_total    │
└─────────────────┘                  │ senia           │
                                     │ observaciones   │
                                     │ fecha_completado│
                                     └─────────────────┘
                                             │
                                             │ 1:N
                        ┌────────────────────┼────────────────────┐
                        │                    │                    │
                        ▼                    ▼                    ▼
              ┌──────────────────┐  ┌──────────────────┐  ┌─────────────┐
              │ PEDIDO_DETALLE   │  │ TAREA_POSTVENTA  │  │    FOTO     │
              │──────────────────│  │──────────────────│  │─────────────│
              │ id (PK)          │  │ id (PK)          │  │ id (PK)     │
              │ pedido_id (FK)   │  │ pedido_id (FK)   │  │ pedido_id   │
              │ producto_id (FK) │  │ titulo           │  │ ruta_archivo│
              │ bizcochuelo_id   │  │ descripcion      │  │ descripcion │
              │ tematica_id (FK) │  │ fecha_limite     │  │ tipo        │
              │ cantidad         │  │ estado           │  │ fecha       │
              │ precio_unitario  │  │ fecha_completado │  └─────────────┘
              │ subtotal         │  │ resultado        │
              │ tamanio          │  └──────────────────┘
              │ observaciones    │
              └──────────────────┘
                      │
                      │ 1:N
                      ▼
              ┌──────────────────┐
              │ DETALLE_RELLENO  │
              │──────────────────│
              │ id (PK)          │
              │ pedido_detalle_id│
              │ relleno_id (FK)  │
              │ capa             │
              │ observaciones    │
              └──────────────────┘
                      │
                      │ N:1
                      ▼
              ┌──────────────────┐
              │    RELLENO       │
              │──────────────────│
              │ id (PK)          │
              │ nombre           │
              │ descripcion      │
              │ activo           │
              └──────────────────┘


┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│   PRODUCTO      │       │  BIZCOCHUELO    │       │   TEMATICA      │
│─────────────────│       │─────────────────│       │─────────────────│
│ id (PK)         │       │ id (PK)         │       │ id (PK)         │
│ nombre          │       │ nombre          │       │ nombre          │
│ descripcion     │       │ descripcion     │       │ descripcion     │
│ precio_base     │       │ activo          │       │ activo          │
│ categoria       │       └─────────────────┘       └─────────────────┘
│ activo          │              ▲                          ▲
└─────────────────┘              │                          │
        ▲                        │ N:1                      │ N:1
        │ N:1                    │                          │
        │                        │                          │
        └────────────────────────┴──────────────────────────┘
                        (Referencias desde PEDIDO_DETALLE)


┌─────────────────┐
│  RECORDATORIO   │
│─────────────────│
│ id (PK)         │
│ cliente_id (FK) │──────► CLIENTE
│ familiar_id (FK)│──────► FAMILIAR
│ titulo          │
│ descripcion     │
│ fecha_evento    │
│ dias_anticipacion│
│ activo          │
│ fecha_recordatorio│
└─────────────────┘
```

## Catálogos Base (Seed Data)

### BIZCOCHUELO (3 registros)
1. Vainilla
2. Chocolate
3. Combinado

### RELLENO (6 registros)
1. DDL con merengues
2. DDL chip chocolate
3. DDL nueces
4. Mousse chocolate
5. Crema pastelera
6. Chantilly con frutas

### TEMATICA (5 registros)
1. Princesas
2. Superhéroes
3. Flores
4. Cumpleaños Clásico
5. Personalizada

### PRODUCTO (3 registros)
1. Torta Clásica - $5000
2. Torta Grande - $8000
3. Bocaditos - $1500

## Índices Creados

```sql
CREATE INDEX idx_cliente_nombre ON cliente(nombre);
CREATE INDEX idx_pedido_cliente ON pedido(cliente_id);
CREATE INDEX idx_pedido_fecha_entrega ON pedido(fecha_entrega);
CREATE INDEX idx_pedido_estado ON pedido(estado);
CREATE INDEX idx_familiar_cliente ON familiar(cliente_id);
```

## Relaciones Clave

1. **Cliente → Familiar**: Un cliente puede tener múltiples familiares registrados
2. **Cliente → Pedido**: Un cliente puede realizar múltiples pedidos
3. **Pedido → PedidoDetalle**: Un pedido puede contener múltiples productos
4. **PedidoDetalle → DetalleRelleno**: Cada producto puede tener múltiples capas de relleno
5. **Pedido → Foto**: Un pedido puede tener múltiples fotos asociadas
6. **Pedido → TareaPostventa**: Un pedido puede tener tareas de seguimiento
7. **Cliente/Familiar → Recordatorio**: Recordatorios para eventos importantes

## Estados de Pedido

- `pendiente`: Pedido recién creado
- `confirmado`: Pedido confirmado por el cliente
- `en_proceso`: Pedido en elaboración
- `completado`: Pedido entregado
- `cancelado`: Pedido cancelado

## Tipos de Foto

- `producto_final`: Foto del producto terminado
- `proceso`: Foto durante la elaboración
- `referencia`: Foto de referencia del cliente
- `otro`: Otros tipos de fotos
