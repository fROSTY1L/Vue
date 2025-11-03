<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase, type Task } from '../lib/supabase'

const tasks = ref<Task[]>([])
const newTaskTitle = ref('')
const loading = ref(false)
const error = ref('')

async function loadTasks() {
  loading.value = true
  error.value = ''

  try {
    const { data, error: fetchError } = await supabase
      .from('tasks')
      .select('*')
      .order('created_at', { ascending: false })

    if (fetchError) throw fetchError
    tasks.value = data || []
  } catch (e) {
    error.value = 'Ошибка загрузки задач'
    console.error(e)
  } finally {
    loading.value = false
  }
}

async function addTask() {
  if (!newTaskTitle.value.trim()) return

  error.value = ''

  try {
    const { data, error: insertError } = await supabase
      .from('tasks')
      .insert([{ title: newTaskTitle.value.trim() }])
      .select()
      .maybeSingle()

    if (insertError) throw insertError
    if (data) tasks.value.unshift(data)
    newTaskTitle.value = ''
  } catch (e) {
    error.value = 'Ошибка добавления задачи'
    console.error(e)
  }
}

async function toggleTask(task: Task) {
  error.value = ''

  try {
    const { error: updateError } = await supabase
      .from('tasks')
      .update({ completed: !task.completed })
      .eq('id', task.id)

    if (updateError) throw updateError
    task.completed = !task.completed
  } catch (e) {
    error.value = 'Ошибка обновления задачи'
    console.error(e)
  }
}

async function deleteTask(id: string) {
  error.value = ''

  try {
    const { error: deleteError } = await supabase
      .from('tasks')
      .delete()
      .eq('id', id)

    if (deleteError) throw deleteError
    tasks.value = tasks.value.filter(task => task.id !== id)
  } catch (e) {
    error.value = 'Ошибка удаления задачи'
    console.error(e)
  }
}

onMounted(() => {
  loadTasks()
})
</script>

<template>
  <div class="task-list">
    <h1>Список задач</h1>

    <div class="add-task">
      <input
        v-model="newTaskTitle"
        @keyup.enter="addTask"
        type="text"
        placeholder="Новая задача..."
        class="task-input"
      />
      <button @click="addTask" class="add-button">Добавить</button>
    </div>

    <div v-if="error" class="error">{{ error }}</div>

    <div v-if="loading" class="loading">Загрузка...</div>

    <div v-else-if="tasks.length === 0" class="empty">
      Задач пока нет. Добавьте первую задачу!
    </div>

    <ul v-else class="tasks">
      <li v-for="task in tasks" :key="task.id" class="task-item">
        <label class="task-label">
          <input
            type="checkbox"
            :checked="task.completed"
            @change="toggleTask(task)"
            class="task-checkbox"
          />
          <span :class="{ completed: task.completed }">{{ task.title }}</span>
        </label>
        <button @click="deleteTask(task.id)" class="delete-button">Удалить</button>
      </li>
    </ul>
  </div>
</template>

<style scoped>
.task-list {
  max-width: 600px;
  margin: 0 auto;
  padding: 24px;
}

h1 {
  font-size: 2em;
  margin-bottom: 24px;
  color: #333;
}

.add-task {
  display: flex;
  gap: 8px;
  margin-bottom: 24px;
}

.task-input {
  flex: 1;
  padding: 12px 16px;
  font-size: 1em;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  transition: border-color 0.2s;
}

.task-input:focus {
  outline: none;
  border-color: #4a90e2;
}

.add-button {
  padding: 12px 24px;
  background-color: #4a90e2;
  color: white;
  border: none;
  border-radius: 8px;
  font-weight: 500;
  cursor: pointer;
  transition: background-color 0.2s;
}

.add-button:hover {
  background-color: #357abd;
}

.error {
  padding: 12px;
  margin-bottom: 16px;
  background-color: #fee;
  color: #c33;
  border-radius: 8px;
  border-left: 4px solid #c33;
}

.loading {
  text-align: center;
  padding: 32px;
  color: #666;
}

.empty {
  text-align: center;
  padding: 32px;
  color: #999;
}

.tasks {
  list-style: none;
  padding: 0;
  margin: 0;
}

.task-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px;
  margin-bottom: 8px;
  background-color: white;
  border: 2px solid #f0f0f0;
  border-radius: 8px;
  transition: all 0.2s;
}

.task-item:hover {
  border-color: #e0e0e0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.task-label {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
}

.task-checkbox {
  width: 20px;
  height: 20px;
  cursor: pointer;
}

.task-label span {
  font-size: 1em;
  color: #333;
  transition: all 0.2s;
}

.task-label span.completed {
  color: #999;
  text-decoration: line-through;
}

.delete-button {
  padding: 8px 16px;
  background-color: #f44336;
  color: white;
  border: none;
  border-radius: 6px;
  font-size: 0.9em;
  cursor: pointer;
  transition: background-color 0.2s;
}

.delete-button:hover {
  background-color: #d32f2f;
}

@media (prefers-color-scheme: light) {
  h1 {
    color: #213547;
  }

  .task-item {
    background-color: #fafafa;
  }

  .task-label span {
    color: #213547;
  }
}
</style>
